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

//        guard let modelPath = Bundle.main.path(forResource: "sequre-combine", ofType: "tflite") else {
        guard let modelPath = Bundle.main.path(forResource: "sequre-v2-od", ofType: "tflite") else {
            fatalError("Failed to load the model file")
        }

        let option = ObjectDetectorOptions(modelPath: modelPath)

        do {
            objectDetector = try ObjectDetector.detector(options: option)
        } catch {
            print("Failed to initialize ObjectDetector: \(error.localizedDescription)")
            objectDetector = nil
        }
    }

    public func detectObject(frame pixelBuffer: CVPixelBuffer) -> Result? {
        if objectDetector == nil { return nil }
        guard let mlImage = MLImage(pixelBuffer: pixelBuffer) else { return nil }
        do {
            let startDate = Date()
            let detectionResult = try objectDetector?.detect(mlImage: mlImage)
            let interval = Date().timeIntervalSince(startDate) * 100

            let filteredDetectionResult = detectionResult?.detections.filter { detection in
                detection.categories.first!.score > 0.115
            }

            if let result = filteredDetectionResult {
                return Result(inferenceTime: interval, detections: result)
            } else {
                return nil
            }

        } catch {
            print("Failed to detect: \(error.localizedDescription)")
            return nil
        }
    }
}
