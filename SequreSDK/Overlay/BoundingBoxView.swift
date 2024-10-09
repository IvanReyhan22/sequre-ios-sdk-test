//
//  BoundingBoxView.swift
//  SequreSDK
//
//  Created by IceQwen on 30/09/24.
//

import Foundation
import UIKit

struct ObjectOverlayBounding {
    let isCapturing: Bool
    let borderRect: CGRect
    let name: String
    let nameStringSize: CGSize
    let color: UIColor
    let font: UIFont
}

/// Scan Corner Overlay
class BoundingBoxView: UIView {
    var objectOverlays: [ObjectOverlayBounding] = []
    private let cornerRadius: CGFloat = 10.0
    private let stringBgAlpha: CGFloat = 0.7
    private let lineWidth: CGFloat = 3
    private let stringFontColor = UIColor.white
    private let stringHorizontalSpacing: CGFloat = 13.0
    private let stringVerticalSpacing: CGFloat = 7.0
    private let staticOverlaySize = CGSize(
        width: UIScreen.main.bounds.width / 1.8,
        height: UIScreen.main.bounds.height / 2.0
    )
    
    private let colorSuccess = UIColor(named: "Quarternary") ?? UIColor.white
    

    override func draw(_ rect: CGRect) {
        /// draw corner indicator
        drawBoundingLimitCornerIndicator(objectOverlays: objectOverlays)

        /// draw border and confidence score around detected object
        /// uncomment for debug
//        for objectOverlay in objectOverlays {
//            drawBorders(of: objectOverlay)
//            drawBackground(of: objectOverlay)
//            drawName(of: objectOverlay)
//        }
    }

    /**
     This method draws the borders of the detected objects.
     */
    func drawBorders(of objectOverlay: ObjectOverlayBounding) {
        let path = UIBezierPath(rect: objectOverlay.borderRect)
        path.lineWidth = lineWidth
        objectOverlay.color.setStroke()
        path.stroke()
    }

    /**
     This method draws the background of the string.
     */
    func drawBackground(of objectOverlay: ObjectOverlayBounding) {
        let stringBgRect = CGRect(
            x: objectOverlay.borderRect.origin.x,
            y: objectOverlay.borderRect.origin.y,
            width: 2 * stringHorizontalSpacing + objectOverlay.nameStringSize.width,
            height: 2 * stringVerticalSpacing + objectOverlay.nameStringSize.height
        )
        let stringBgPath = UIBezierPath(rect: stringBgRect)

        objectOverlay.color.withAlphaComponent(stringBgAlpha).setFill()
        stringBgPath.fill()
    }

    /**
     This method draws the name of object overlay.
     */
    func drawName(of objectOverlay: ObjectOverlayBounding) {
        // Draws the string.
        let stringRect = CGRect(
            x: objectOverlay.borderRect.origin.x + stringHorizontalSpacing,
            y: objectOverlay.borderRect.origin.y + stringVerticalSpacing,
            width: objectOverlay.nameStringSize.width,
            height: objectOverlay.nameStringSize.height
        )

        let attributedString = NSAttributedString(
            string: objectOverlay.name,
            attributes: [
                NSAttributedString.Key.foregroundColor: stringFontColor,
                NSAttributedString.Key.font: objectOverlay.font,
            ]
        )
        attributedString.draw(in: stringRect)
    }

    /// draw square bounding indicator
    func drawBoundingLimitCornerIndicator(objectOverlays: [ObjectOverlayBounding]) {
        let overlayRect = CGRect(
            x: (UIScreen.main.bounds.width - staticOverlaySize.width) / 2,
            y: (UIScreen.main.bounds.height - staticOverlaySize.height) / 2,
            width: staticOverlaySize.width,
            height: staticOverlaySize.height
        )

        if let firstOverlay = objectOverlays.first {
            let isSystemCapturing = firstOverlay.isCapturing

            drawCornerIndicators(overlayRect: overlayRect, isCapturing: isSystemCapturing)
        } else {
            drawCornerIndicators(overlayRect: overlayRect, isCapturing: false)
        }
    }

    /// draw corner indicator
    func drawCornerIndicators(overlayRect: CGRect, isCapturing: Bool) {
        // Corner line length and thickness
        let cornerLength: CGFloat = 31.0
        let cornerThickness: CGFloat = 5.0
        
        var cornerColor: UIColor = UIColor(named:"PrimaryApp") ?? .white
        //        let cornerColor:UIColor = isCapturing ?
        //        UIColor(named: "Quarternary", in: bundle, compatibleWith: nil)! :UIColor(named: "Color3E405F", in: bundle, compatibleWith: nil)!
        
        if let bundleURL = Bundle(for: SequreSDK.self).url(forResource: "SequreSDKAssets", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL) {
            
            let quarternaryColor = UIColor(named: "Quarternary", in: bundle, compatibleWith: nil)
            let color3E405F = UIColor(named: "Color3E405F", in: bundle, compatibleWith: nil)
            
            // Use the colors if found
            if let quarternaryColor = quarternaryColor, let color3E405F = color3E405F {
                // Apply the colors as needed
                cornerColor = isCapturing ?  quarternaryColor : color3E405F
            } else {
                print("One or more colors not found in the bundle")
            }
            
        }


        let offset: CGFloat = 10.0 // Adjust for better alignment of corners
        let topLeft = CGPoint(x: overlayRect.minX - offset, y: overlayRect.minY - offset)
        let topRight = CGPoint(x: overlayRect.maxX + offset, y: overlayRect.minY - offset)
        let bottomLeft = CGPoint(x: overlayRect.minX - offset, y: overlayRect.maxY + offset)
        let bottomRight = CGPoint(x: overlayRect.maxX + offset, y: overlayRect.maxY + offset)

        // Draw corners
        drawCorner(at: topLeft, length: cornerLength, thickness: cornerThickness, color: cornerColor, isTopLeft: true)
        drawCorner(at: topRight, length: cornerLength, thickness: cornerThickness, color: cornerColor, isTopLeft: false)
        drawCorner(at: bottomLeft, length: cornerLength, thickness: cornerThickness, color: cornerColor, isTopLeft: true, isTop: false)
        drawCorner(at: bottomRight, length: cornerLength, thickness: cornerThickness, color: cornerColor, isTopLeft: false, isTop: false)
    }

    /// draw corner line
    func drawCorner(
        at point: CGPoint,
        length: CGFloat,
        thickness: CGFloat,
        color: UIColor,
        isTopLeft: Bool,
        isTop: Bool = true
    ) {
        let path = UIBezierPath()
        color.setStroke()
        path.lineWidth = thickness

        path.move(to: point)

        /// Horizontal line
        if isTopLeft {
            path.addLine(to: CGPoint(x: point.x + length, y: point.y))
        } else {
            path.addLine(to: CGPoint(x: point.x - length, y: point.y))
        }

        /// Vertical line
        if isTop {
            /// Move back to the origin point
            path.move(to: CGPoint(x: point.x, y: point.y - 2.5))
            path.addLine(to: CGPoint(x: point.x, y: point.y + length))
        } else {
            /// Move back to the origin point
            path.move(to: CGPoint(x: point.x, y: point.y + 2.5))
            path.addLine(to: CGPoint(x: point.x, y: point.y - length))
        }

        path.stroke()
    }
}
