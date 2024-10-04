//
//  ImageOperation.swift
//  SequreSDK
//
//  Created by IceQwen on 03/10/24.
//

import Foundation
import SwiftUI

/// crop image based on rect
func cropImage(image: UIImage, boundingBox: CGRect) -> UIImage? {
    // add padding to bounded box
    let padding: CGFloat = 150
    let paddedBoundingBox = boundingBox.insetBy(dx: -padding, dy: -padding)
    
    let croppedRect = paddedBoundingBox.intersection(
        CGRect(origin: .zero, size: image.size)
    )
    
    guard let cgImage = image.cgImage?.cropping(to: croppedRect) else {
        return nil
    }
    return UIImage(cgImage: cgImage)
}

func generateTimestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    return formatter.string(from: Date())
}

func saveImageToDocuments(_ image: UIImage) -> URL? {
    if let data = image.jpegData(compressionQuality: 1) {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileName = generateTimestamp()
        
        let fileUrl = documentPath.appendingPathComponent("\(fileName).jpeg")
        
        do {
            try data.write(to: fileUrl)
            
            return fileUrl
        } catch {
            return nil
        }
    }
    
    return nil
}

func convertToGrayscale(image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    
    let context = CIContext()
    let ciImage = CIImage(cgImage: cgImage)
    let grayscale = ciImage.applyingFilter("CIColorControls", parameters: ["inputSaturation": 0.0])
    
    if let outputCGImage = context.createCGImage(grayscale, from: grayscale.extent) {
        return UIImage(cgImage: outputCGImage)
    }
    
    return nil
}
