import UIKit
import CoreVideo
import TensorFlowLiteTaskVision

class BlurDetector {
    private let threshold: Double = 50.0

    func isImageBlurred(image: UIImage) -> Bool {
        guard let pixelBuffer = image.toPixelBuffer() else { return false }
        
        let blurScore = calculateBlurScore(pixelBuffer)
        print("blur score \(blurScore)")
        return blurScore < threshold 
    }

    private func calculateBlurScore(_ pixelBuffer: CVPixelBuffer) -> Double {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let filter = CIFilter(name: "CISobelEdgeDetection")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else { return 0.0 }
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)!
        
        let bitmapData = cgImage.dataProvider!.data
        let data = CFDataGetBytePtr(bitmapData)
        var brightnessSum = 0.0
        let width = cgImage.width
        let height = cgImage.height

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = ((width * y) + x) * 4
                let brightness = Double(data![pixelIndex]) 
                brightnessSum += brightness
            }
        }

        return brightnessSum / Double(width * height)
    }
}

extension UIImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!
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
        
        guard status == noErr, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, [])
        
        return unwrappedPixelBuffer
    }
}