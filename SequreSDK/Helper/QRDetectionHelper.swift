//
//  QRDetectionHelper.swift
//  SequreSDK
//
//  Created by IceQwen on 30/09/24.
//

import TensorFlowLiteTaskVision

public struct Result {
    let inferenceTime: Double
    public let detections: [Detection]
}

public class QRDetectionHelper: NSObject {
    private var objectDetector: ObjectDetector?
    
    override public init() {
        super.init()
        
        let frameworkBundle = Bundle(for: QRDetectionHelper.self)
        
        guard let modelPath = frameworkBundle.path(forResource: "sequre-v2-od", ofType: "tflite") else {
            fatalError("Failed to load the model file")
        }
        
        let option = ObjectDetectorOptions(modelPath: modelPath)
        
        do {
            objectDetector = try ObjectDetector.detector(options: option)
        } catch {
            print("Failed to run interfence \(error.localizedDescription)")
        }
    }
    
    public func detectObject(frame pixelBuffer: CVPixelBuffer) -> Result? {
        guard let mlImage = MLImage(pixelBuffer: pixelBuffer) else { return nil }
        do {
            let startDate = Date()
            let detectionResult = try objectDetector!.detect(mlImage: mlImage)
            let interval = Date().timeIntervalSince(startDate) * 100
            
            let filteredDetectionResult = detectionResult.detections.filter { detection in
                return detection.categories.first!.score > 0.115
            }
            
            return Result(inferenceTime: interval, detections: filteredDetectionResult)
            
        } catch {
            return nil
        }
    }
}
