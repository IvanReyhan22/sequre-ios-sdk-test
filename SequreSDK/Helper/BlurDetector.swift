import UIKit
import CoreVideo
import TensorFlowLiteTaskVision

class BlurDetector {
    private let threshold: Double = 50.0

    /// Check if the image is blurred
    func isImageBlurred(image: UIImage) -> Bool {
        guard let pixelBuffer = image.toPixelBuffer() else { return false }
        
        let blurScore = calculateBlurScore(pixelBuffer)
        print("Blur score: \(blurScore)")
        return blurScore < threshold
    }

    /// Calculate blur score based on brightness values
    private func calculateBlurScore(_ pixelBuffer: CVPixelBuffer) -> Double {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Apply edge detection filter
        guard let filter = CIFilter(name: "CISobelEdgeDetection") else { return 0.0 }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return 0.0 }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return 0.0 }
        
        // Extract brightness data from the image
        guard let bitmapData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(bitmapData) else { return 0.0 }

        let width = cgImage.width
        let height = cgImage.height
        let totalPixels = width * height
        var brightnessSum = 0.0

        // Sum brightness values for all pixels
        for pixelIndex in stride(from: 0, to: totalPixels * 4, by: 4) {
            brightnessSum += Double(data[pixelIndex])
        }

        // Return the average brightness as the blur score
        return brightnessSum / Double(totalPixels)
    }
}

extension UIImage {
    /// Convert UIImage to CVPixelBuffer
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        // Pixel buffer attributes
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            pixelBufferAttributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, []) }
        
        guard let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer) else {
            return nil
        }

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        // Safely unwrap and draw the image
        guard let cgImage = self.cgImage else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return unwrappedPixelBuffer
    }
}
