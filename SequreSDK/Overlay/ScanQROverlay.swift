//
//  ScanQROverlay.swift
//  SequreSDK
//
//  Created by IceQwen on 02/10/24.
//

import SwiftUI

/// Square QR Bounding Box Overlay
class ScanQROverlay: UIView {
    override func draw(_ rect: CGRect) {
        scanOverlay(in: rect)
    }
    
    private func scanOverlay(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
        context?.fill(bounds)
        
        let cutoutRect = CGRect(
            x: bounds.width / 2 - (bounds.width / 1.8) / 2,
            y: bounds.height / 2 - (bounds.height / 2.0) / 2,
            width: bounds.width / 1.8,
            height: bounds.height / 2.0
        )
        
        context?.setBlendMode(.clear)
        context?.fill(cutoutRect)
    }
}
