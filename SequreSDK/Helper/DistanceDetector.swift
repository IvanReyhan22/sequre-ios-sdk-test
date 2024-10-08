//
//  DistanceDetector.swift
//  SequreSDK
//
//  Created by IceQwen on 02/10/24.
//

import Foundation
import SwiftUI
import TensorFlowLiteTaskVision

class DistanceDetector {
    /// define overlaySize
    let staticOverlaySize = CGSize(
        width: UIScreen.main.bounds.width / 1.8,
        height: UIScreen.main.bounds.height / 2.0
    )
    
    /// define threshold for object size relative to camera sensor
    let minSizeThreshold: CGFloat = 2.0
    let minIpadSizeThreshold: CGFloat = 1.0
    let maxSizeThreshold: CGFloat = 3.5
    
    /// calulate object distance function
    public func detectObjectDistance(
        originalImage: UIImage?,
        detectedObjects: [Detection],
        capturing: Bool
    ) -> DistanceResult {
        /// get first detected object
        guard let detectedObject = detectedObjects.first else {
            return DistanceResult.notDetected
        }
        
        /// retrieved bounding box from detected object data
        let boundingBox = detectedObject.boundingBox
        
        // Define the frame of the static overlay in the view's coordinate
        let staticOverlayFrame = CGRect(
            x: (UIScreen.main.bounds.width - staticOverlaySize.width) / 2,
            y: (UIScreen.main.bounds.height - staticOverlaySize.height) / 2,
            width: staticOverlaySize.width,
            height: staticOverlaySize.height
        )
        
        // convert image scale to device screen scale
        let convertedBoundingBox = boundingBox.applying(
            CGAffineTransform(
                scaleX: UIScreen.main.bounds.width / originalImage!.size.width,
                y: UIScreen.main.bounds.height / originalImage!.size.height
            )
        )
        
        /// calculate object ratio
        let widthRatio = boundingBox.width / staticOverlaySize.width
        let heightRatio = boundingBox.height / staticOverlaySize.width
        let averageRatio = (widthRatio + heightRatio) / 2
        
        /// get device type
        let deviceType = UIDevice.current.userInterfaceIdiom
        var minThreshold = minSizeThreshold
        
        /// adjust threshold based on device type
        switch deviceType {
        case .pad:
            minThreshold = minIpadSizeThreshold
        case .phone:
            minThreshold = minSizeThreshold
        default:
            minThreshold = minSizeThreshold
        }
        
        // check if the object is not inside the overlay
        if !(convertedBoundingBox.minX >= staticOverlayFrame.minX
            && convertedBoundingBox.minY >= staticOverlayFrame.minY
            && convertedBoundingBox.maxX <= staticOverlayFrame.maxX
            && convertedBoundingBox.maxY <= staticOverlayFrame.maxY)
        {
            if !capturing, convertedBoundingBox.intersects(staticOverlayFrame) {
                if averageRatio > maxSizeThreshold {
                    return DistanceResult.tooClose
                }
                
                return DistanceResult.outOfArea
            }
            
            return DistanceResult.notDetected
        }
        
        if averageRatio < minThreshold {
            return DistanceResult.tooFar
        } else if averageRatio > maxSizeThreshold {
            return DistanceResult.tooClose
        } else {
            return DistanceResult.optimal
        }
    }
}
