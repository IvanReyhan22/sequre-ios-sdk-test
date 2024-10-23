//
//  QRScannerPage.swift
//  SequreSDK
//
//  Created by IceQwen on 03/10/24.
//

import AVFoundation
import Foundation
import SwiftUI
import TensorFlowLiteTaskVision

public struct QRScannerPage: View {
    private var distanceDetector = DistanceDetector()
    /// object detected model data
    @StateObject private var detectedObjectData = DetectedObjectModel()
    
    @State private var distanceResult = DistanceResult.notDetected
    
    /// detect if user uploading image to api
    @State private var capturing: Bool = false
    
    /// control to turn on / off flash
    @State var isFlashActive: Bool = true
    /// indicate wether device support flash
    @State private var hasFlash: Bool = true
    
    @State private var zoomLevel: CGFloat = 3.0
    
    @State private var originalImage: UIImage? = nil
    @State private var croppedImage: UIImage? = nil
    @State private var isImageCropped: Bool = false
    
    /// controll loading sheet
    @State private var isLoading: Bool = false
    
    var isDebugLayout: Bool
    
    @StateObject private var viewModel = SDKScanViewModel()
    
    /// return status dialog scan
    public var onQRResult: (StatusDialogScan?) -> Void
    public var returnScanModel: ((String, UIImage) -> Void)?

    @Binding var restartSession: Bool
    @Binding var pauseSession: Bool

    @State var showNetworkError: Bool = false
    @State var showMaxLimit: Bool = false
    @State var showMinLimit: Bool = false
    @State var countMaxLimit: Int8 = 0
    @State var countMinLimit: Int8 = 0
    
    public init(
        restartSession: Binding<Bool>,
        pauseSession: Binding<Bool>,
        onQRResult: @escaping (StatusDialogScan?) -> Void,
        isDebugLayout: Bool = false,
        returnScanModel: ((String, UIImage) -> Void)? = nil
    ) {
        self._restartSession = restartSession
        self._pauseSession = pauseSession
        self.onQRResult = onQRResult
        self.returnScanModel = returnScanModel
        self.isDebugLayout = isDebugLayout
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                /// camera feed
                QRCameraFeedController(
                    detectedObjectData: detectedObjectData,
                    imageSource: $originalImage,
                    isFlashActive: $isFlashActive,
                    hasFlash: $hasFlash,
                    isCapturing: $capturing,
                    zoomLevel: $zoomLevel,
                    distanceResult: $distanceResult,
                    isDebugLayout: isDebugLayout
                )
                
                /// flash and version control
                VStack {
                    HStack {
                        /// version indicator
                        Text(
                            "v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "1")"
                        )
                        .foregroundColor(Color.white)
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        /// flash controller
                        if hasFlash {
                            Button {
                                isFlashActive.toggle()
                            } label: {
                                if let bundleURL = Bundle(for: SequreSDK.self).url(forResource: "SequreSDKAssets", withExtension: "bundle"),
                                   let bundle = Bundle(url: bundleURL)
                                {
                                    // Bundle found, now try to load the image
                                    if let image = UIImage(named: isFlashActive ? "icFlashActive" : "icFlashInactive", in: bundle, compatibleWith: nil) {
                                        Image(uiImage: image)
                                            .frame(width: 82)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.leading, 18)
                    .padding(.trailing, 0)
                    
                    Spacer()
                }
                .padding(.top, geo.safeAreaInsets.top + 50)
                .background(.clear)
            }
        }
        .onChange(of: detectedObjectData.detectedObjects) { _ in
            if !pauseSession {
                submitDetection()
            }
        }
        .onChange(of: restartSession) { value in
            if value {
                isFlashActive = true
                capturing = false
                zoomLevel = 3
                restartSession = false
                countMaxLimit = 0
                countMinLimit = 0
            }
        }
        .toast("Max zoom reached", isShowing: $showMaxLimit)
        .toast("Min zoom reached", isShowing: $showMinLimit)
        .toast("Network Error! Please check your connection.", isShowing: $showNetworkError)
    }
    
    private func handleZoomLevel() {
        var maxZoom: CGFloat = 5
        var minZoom: CGFloat = 1
        
        if let deviceIn = AVCaptureDevice.default(for: .video) {
            maxZoom = deviceIn.maxAvailableVideoZoomFactor
            minZoom = deviceIn.minAvailableVideoZoomFactor
        }
        
        if distanceResult == DistanceResult.tooClose {
            if minZoom < zoomLevel {
                zoomLevel -= 0.1
            } else if countMaxLimit == 0 {
                showMaxLimit = true
                countMaxLimit += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    countMaxLimit = 0
                }
            }
        }
        
        if distanceResult == DistanceResult.tooFar {
            if maxZoom > zoomLevel {
                zoomLevel += 0.1
            } else if countMinLimit == 0 {
                showMinLimit = true
                countMinLimit += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    countMinLimit = 0
                }
            }
        }
    }
    
    /// detect qr based on position
    /// if condition is true upload qr on cloud
    private func submitDetection() {
        if capturing, !pauseSession { return }
        
        distanceResult = distanceDetector.detectObjectDistance(
            originalImage: originalImage,
            detectedObjects: detectedObjectData.detectedObjects,
            capturing: capturing
        )
        
        if distanceResult == DistanceResult.tooClose || distanceResult == DistanceResult.tooFar {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                if distanceResult == DistanceResult.tooClose || distanceResult == DistanceResult.tooFar {
//                    self.zoomLevel += (distanceResult == .tooFar) ? 0.1 : -0.1
//                }
                handleZoomLevel()
            }
            return
        }
        
        if distanceResult == .notDetected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if zoomLevel == 3 {
                    return
                }
                if zoomLevel > 3 {
                    zoomLevel -= 0.1
                } else if zoomLevel < 3 {
                    zoomLevel += 0.1
                }
            }
        }
        
        if distanceResult == DistanceResult.optimal {
            capturing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard let boundingBox = self.detectedObjectData.detectedObjects.first?.boundingBox else {
                    distanceResult = .notDetected
                    capturing = false
                    return
                }
                if !isImageCropped, let image = originalImage, capturing {
                    croppedImage = cropImage(image: image, boundingBox: boundingBox)
                    
                    if let croppedImage = croppedImage {
                        isImageCropped = true

                        if let imageUrl = saveImageToDocuments(croppedImage) {
                            let isInvalid = viewModel.checkInvalidQrImage(from: imageUrl)
                            if isInvalid {
                                capturing = false
                                distanceResult = .blur
                                isImageCropped = false
                            } else {
                                isLoading = true
                                viewModel.uploadImage(
                                    imageFile: imageUrl,
                                    onPostExecuted: {
                                        distanceResult = .notDetected
                                        isFlashActive = false
                                    },
                                    returnScanModel: { model in
                                        returnScanModel?(model.displayInfo(), croppedImage)
                                    }
                                ) { dialogStatus in
                                    if dialogStatus == nil {
                                        withAnimation {
                                            showNetworkError = true
                                            restartSession = true
                                        }
                                    }
                                    isImageCropped = false
                                    isLoading = false
                                    onQRResult(dialogStatus)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
