//
//  DetectedObjectData.swift
//  SequreSDK
//
//  Created by IceQwen on 27/09/24.
//

import Combine
import TensorFlowLiteTaskVision

public class DetectedObjectModel: ObservableObject {
    @Published public var detectedObjects: [Detection] = []
}
