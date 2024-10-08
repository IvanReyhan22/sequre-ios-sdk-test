//
//  CustomFont.swift
//  SequreSDK
//
//  Created by Andi Surya on 8/29/24.
//

import SwiftUI

enum CustomFontWeight {
    case light
    case regular
    case medium
    case bold
    case black
}

extension Font {
    static let customFont: (CustomFontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .light:
            Font.custom("Montserrat-Light", size: size)
        case .regular:
            Font.custom("Montserrat-Regular", size: size)
        case .medium:
            Font.custom("Montserrat-Medium", size: size)
        case .bold:
            Font.custom("Montserrat-Bold", size: size)
        case .black:
            Font.custom("Montserrat-Black", size: size)
        }
    }
}

/// Custom font extension
extension Text {
    func customFont(_ fontWeight: CustomFontWeight? = .regular, _ size: CGFloat? = nil) -> Text {
        return self.font(.customFont(fontWeight ?? .regular, size ?? 16))
    }
}
