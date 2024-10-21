//
//  LabelOverlay.swift
//  SequreSDK
//
//  Created by IceQwen on 02/10/24.
//

import UIKit

class LabelOverlay: UIView {
    var qrDistanceResult: DistanceResult = .notDetected
    
    override func draw(_ rect: CGRect) {
        if qrDistanceResult != .notDetected {
            drawLabel(in: rect)
        }
    }
    
    private func drawLabel(in rect: CGRect) {
        /// scan overflow cutout position
        let cutoutRect = CGRect(
            x: bounds.width / 2 - (bounds.width / 1.8) / 2,
            y: bounds.height / 2 - (bounds.height / 2.0) / 2,
            width: bounds.width / 1.8,
            height: bounds.height / 2.0
        )
        
        // Text localized for warning message
        let text: String? = {
            switch qrDistanceResult {
            case .tooClose:
                return NSLocalizedString("Too Close", comment: "Too Close")
            case .tooFar:
                return NSLocalizedString("Too Far", comment: "Too Far")
            case .optimal:
                return NSLocalizedString("Hold Steady", comment: "Hold Steady")
            case .outOfArea:
                return NSLocalizedString("Object out of the area", comment: "Object out of the area")
            case .blur:
                return nil
            default:
                return ""
            }
        }()
        
        if let text = text {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]
        
            /// Calculate the size of the text
            let textSize = (text as NSString).size(withAttributes: attributes)
        
            /// Position the text in the cutout rectangle
            let textRect = CGRect(
                x: cutoutRect.midX - textSize.width / 2,
                y: cutoutRect.maxY - textSize.height - 30,
                width: textSize.width,
                height: textSize.height
            )
        
            /// Create a background behind the text
            let backgroundRect = CGRect(
                x: textRect.origin.x - 10,
                y: textRect.origin.y - 5,
                width: textRect.width + 20,
                height: textRect.height + 10
            )
        
            let cornerRadius: CGFloat = 8
            let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
        
            /// Draw the rounded background
            UIColor(named: "PrimaryApp", in: bundle, compatibleWith: nil)?.setFill()
            backgroundPath.fill()
        
            /// Draw the text on top of the background
            (text as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
}
