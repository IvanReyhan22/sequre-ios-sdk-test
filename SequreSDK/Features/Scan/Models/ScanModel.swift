//
//  ScanModel.swift
//  SequreSDK
//
//  Created by admin on 18/09/24.
//

extension ScanModel {
    func displayInfo() -> String {
        var result = ""
        
        result += "PID: \(pid ?? "N/A")\n"
        result += "Email Sent: \(emailSent?.description ?? "N/A")\n"
        
        if let canvas = canvas {
            result += "Canvas:\n"
            result += "  Model Used: \(canvas.modelUsed ?? "N/A")\n"
            result += "  File Size: \(canvas.fileSize?.description ?? "N/A")\n"
            result += "  Status: \(canvas.status ?? "N/A")\n"
        }

        if let classification = classification {
            result += "Classification:\n"
            result += "  Label: \(classification.label ?? "N/A")\n"
            result += "  Model Used: \(classification.modelUsed ?? "N/A")\n"
            result += "  Score: \(classification.score?.description ?? "N/A")\n"
            result += "  Status: \(classification.status ?? "N/A")\n"
        }

        if let qrcode = qrcode {
            result += "QR Code:\n"
            result += "  Text: \(qrcode.text ?? "N/A")\n"
            result += "  Type: \(qrcode.type ?? "N/A")\n"
            result += "  Status: \(qrcode.status ?? "N/A")\n"
        }

        return result
    }
}

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
