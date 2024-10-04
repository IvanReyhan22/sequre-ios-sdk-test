//
//  SpacingExtension.swift
//  SequreSDK
//
//  Created by Andi Surya on 8/30/24.
//

import SwiftUI

extension Double {
    var horizontalSpace: some View {
        Spacer().frame(width: self)
    }

    var verticalSpace: some View {
        Spacer().frame(height: self)
    }
}
