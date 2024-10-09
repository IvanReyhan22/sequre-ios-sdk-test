//
//  ScanModel.swift
//  SequreSDK
//
//  Created by admin on 18/09/24.
//

import Foundation

public struct ScanModel: Codable {
    let canvas: Canvas?
    let classification: Classification?
    let emailSent: Bool?
    let object: Canvas?
    let originals: Originals?
    let pid: String?
    let qrcode: Qrcode?

    enum CodingKeys: String, CodingKey {
        case canvas, classification
        case emailSent = "email_sent"
        case object, originals, pid, qrcode
    }
}

public struct Canvas: Codable {
    let boundingBox: BoundingBox?
    let dimensions: Dimensions?
    let fileSize: Int?
    let modelUsed: String?
    let score: Double?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case boundingBox = "bounding_box"
        case dimensions
        case fileSize = "file_size"
        case modelUsed = "model_used"
        case score, status
    }
}

public struct BoundingBox: Codable {
    let bottomRight, topLeft: [Double]?

    enum CodingKeys: String, CodingKey {
        case bottomRight = "bottom_right"
        case topLeft = "top_left"
    }
}

public struct Dimensions: Codable {
    let height, width: Int?
}

public struct Classification: Codable {
    let dimensions: Dimensions?
    let filePath: String?
    let fileSize: Int?
    let label: String?
    let labelIndex: Int?
    let modelUsed: String?
    let score: Double?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case dimensions
        case filePath = "file_path"
        case fileSize = "file_size"
        case label
        case labelIndex = "label_index"
        case modelUsed = "model_used"
        case score, status
    }
}

public struct Originals: Codable {
    let dimensions: Dimensions?
    let filePath: String?
    let fileSize: Int?
    let format: String?

    enum CodingKeys: String, CodingKey {
        case dimensions
        case filePath = "file_path"
        case fileSize = "file_size"
        case format
    }
}

public struct Qrcode: Codable {
    let rect: Rect?
    let status, text, type: String?
}

public struct Rect: Codable {
    let height, rectLeft, top, width: Int?

    enum CodingKeys: String, CodingKey {
        case height
        case rectLeft = "left"
        case top, width
    }
}
