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
            
            // Canvas Section
            if let canvas = canvas {
                result += "Canvas:\n"
                result += "  Model Used: \(canvas.modelUsed ?? "N/A")\n"
                result += "  File Size: \(canvas.fileSize?.description ?? "N/A")\n"
                result += "  Status: \(canvas.status ?? "N/A")\n"
                
                if let boundingBox = canvas.boundingBox {
                    result += "  Bounding Box:\n"
                    result += "    Bottom Right: \(boundingBox.bottomRight?.description ?? "N/A")\n"
                    result += "    Top Left: \(boundingBox.topLeft?.description ?? "N/A")\n"
                }
                if let dimensions = canvas.dimensions {
                    result += "  Dimensions:\n"
                    result += "    Height: \(dimensions.height?.description ?? "N/A")\n"
                    result += "    Width: \(dimensions.width?.description ?? "N/A")\n"
                }
                result += "  Score: \(canvas.score?.description ?? "N/A")\n"
            }
            
            // Classification Section
            if let classification = classification {
                result += "Classification:\n"
                result += "  Label: \(classification.label ?? "N/A")\n"
                result += "  File Size: \(String(describing: classification.fileSize))\n"
                result += "  Model Used: \(classification.modelUsed ?? "N/A")\n"
                result += "  Score: \(classification.score?.description ?? "N/A")\n"
                result += "  Status: \(classification.status ?? "N/A")\n"
                
                if let dimensions = classification.dimensions {
                    result += "  Dimensions:\n"
                    result += "    Height: \(dimensions.height?.description ?? "N/A")\n"
                    result += "    Width: \(dimensions.width?.description ?? "N/A")\n"
                }
                result += "  File Path: \(classification.filePath ?? "N/A")\n"
                result += "  Label Index: \(classification.labelIndex?.description ?? "N/A")\n"
            }
            
            // Object Section (This seems to be a duplicate of Canvas, so it can be added conditionally or removed if redundant)
            if let object = object {
                result += "Object:\n"
                result += "  File Size: \(String(describing: object.fileSize))\n"
                result += "  Score: \(object.score?.description ?? "N/A")\n"
                result += "  Status: \(object.status ?? "N/A")\n"
                
                if let boundingBox = object.boundingBox {
                    result += "  Bounding Box:\n"
                    result += "    Bottom Right: \(boundingBox.bottomRight?.description ?? "N/A")\n"
                    result += "    Top Left: \(boundingBox.topLeft?.description ?? "N/A")\n"
                }
                if let dimensions = object.dimensions {
                    result += "  Dimensions:\n"
                    result += "    Height: \(dimensions.height?.description ?? "N/A")\n"
                    result += "    Width: \(dimensions.width?.description ?? "N/A")\n"
                }
            }

            // Originals Section
            if let originals = originals {
                result += "Originals:\n"
                result += "  File Path: \(originals.filePath ?? "N/A")\n"
                result += "  File Size: \(String(describing: originals.fileSize))\n"
                result += "  Format: \(originals.format ?? "N/A")\n"
                
                if let dimensions = originals.dimensions {
                    result += "  Dimensions:\n"
                    result += "    Height: \(dimensions.height?.description ?? "N/A")\n"
                    result += "    Width: \(dimensions.width?.description ?? "N/A")\n"
                }
            }
            
            // QR Code Section
            if let qrcode = qrcode {
                result += "QR Code:\n"
                result += "  Text: \(qrcode.text ?? "N/A")\n"
                result += "  Type: \(qrcode.type ?? "N/A")\n"
                result += "  Status: \(qrcode.status ?? "N/A")\n"
                
                if let rect = qrcode.rect {
                    result += "  Rect:\n"
                    result += "    Height: \(rect.height?.description ?? "N/A")\n"
                    result += "    Left: \(rect.rectLeft?.description ?? "N/A")\n"
                    result += "    Top: \(rect.top?.description ?? "N/A")\n"
                    result += "    Width: \(rect.width?.description ?? "N/A")\n"
                }
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
