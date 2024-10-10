//
//  CameraController.swift
//  SequreSDK
//
//  Created by IceQwen on 30/09/24.
//
import SwiftUI

public struct QRCameraFeedController: UIViewControllerRepresentable {
    @ObservedObject var detectedObjectData: DetectedObjectModel
    @Binding var imageSource: UIImage?
    @Binding var isFlashActive: Bool
    @Binding var hasFlash: Bool
    @Binding var isCapturing: Bool
    @Binding var zoomLevel: CGFloat
    @Binding var distanceResult: DistanceResult
    
    public init(
        detectedObjectData: DetectedObjectModel,
        imageSource: Binding<UIImage?>,
        isFlashActive: Binding<Bool>,
        hasFlash: Binding<Bool>,
        isCapturing: Binding<Bool>,
        zoomLevel: Binding<CGFloat>,
        distanceResult: Binding<DistanceResult>
    ) {
        self.detectedObjectData = detectedObjectData
        self._imageSource = imageSource
        self._isFlashActive = isFlashActive
        self._hasFlash = hasFlash
        self._isCapturing = isCapturing
        self._zoomLevel = zoomLevel
        self._distanceResult = distanceResult
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController(
            detectedObjectData: detectedObjectData,
            imageSource: $imageSource,
            hasFlash: $hasFlash,
            isFlashActive: $isFlashActive,
            isCapturing: $isCapturing,
            distanceResult: $distanceResult
        )
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let cameraController = uiViewController as? ViewController {
            
            /// update torch
            cameraController.toggleFlash(on: isFlashActive)
            
            /// update zoom level
            cameraController.changeZoomLevel(zoomLevel: zoomLevel)
            
            /// add auto focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cameraController.doAutoFocus()
            }
        
        }
    }
}
