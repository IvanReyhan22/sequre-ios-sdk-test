//
//  QRScannerPage.swift
//  SequreSDK
//
//  Created by IceQwen on 03/10/24.
//

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
    @State private var isFlashActive: Bool = true
    /// indicate wether device support flash
    @State private var hasFlash: Bool = true
    
    @State private var zoomLevel: CGFloat = 3.0
    
    @State private var originalImage: UIImage? = nil
    @State private var croppedImage: UIImage? = nil
    @State private var isImageCropped: Bool = false
    
    /// controll loading sheet
    @State private var isLoading: Bool = false
    
    @StateObject private var viewModel = SDKScanViewModel()
    
    /// return status dialog scan
    public var onQRResult: (StatusDialogScan) -> Void
    
    @Binding var restartSession: Bool
    @Binding var pauseSession: Bool
    
    public init(
        restartSession: Binding<Bool>,
        pauseSession: Binding<Bool>,
        onQRResult: @escaping (StatusDialogScan) -> Void
    ) {
        self.onQRResult = onQRResult
        self._restartSession = restartSession
        self._pauseSession = pauseSession
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
                    distanceResult: $distanceResult
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
                                   let bundle = Bundle(url: bundleURL) {
                                    // Bundle found, now try to load the image
                                    if let image = UIImage(named: isFlashActive ? "icFlashActive" : "icFlashInactive", in: bundle, compatibleWith: nil) {
                                        Image(uiImage: image)
                                            .frame(width: 82)
                                    } else {
                                        Text("Image not found in SequreSDKAssets bundle").foregroundColor(.white)
//                                        print("Image not found in SequreSDKAssets bundle")
                                    }
                                } else {
                                    Text("SequreSDKAssets bundle not found").foregroundColor(.white)
//                                    print("SequreSDKAssets bundle not found")
                                }

//                                Image(isFlashActive ? "icFlashActive" : "icFlashInactive", bundle: bundle)
//                                    .frame(width: 82)
                                
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
                if distanceResult == DistanceResult.tooClose || distanceResult == DistanceResult.tooFar {
                    self.zoomLevel += (distanceResult == .tooFar) ? 0.3 : -0.3
                    // self.zoomLevel += (distanceResult == .tooFar) ? 0.4 : -0.4
                }
            }
            return
        }
        
        if distanceResult == .notDetected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                zoomLevel = 3
            }
        }
        
        if distanceResult == DistanceResult.optimal {
            capturing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                guard let boundingBox = self.detectedObjectData.detectedObjects.first?.boundingBox else {
                    distanceResult = .notDetected
                    zoomLevel = 3
                    capturing = false
                    return
                }
                
                isLoading = true
                if !isImageCropped, let image = originalImage, capturing {
                    croppedImage = cropImage(image: image, boundingBox: boundingBox)
                    
                    if let croppedImage = croppedImage {
                        isImageCropped = true
                        
                        if let imageUrl = saveImageToDocuments(croppedImage) {
                            viewModel.uploadImage(
                                imageFile: imageUrl,
                                onPostExecuted: {
                                    distanceResult = .notDetected
                                    isFlashActive = false
                                }
                            ) { dialogStatus in
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
