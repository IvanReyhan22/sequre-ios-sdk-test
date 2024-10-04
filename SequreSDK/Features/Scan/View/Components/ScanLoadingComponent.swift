//
//  ScanLoadingComponent.swift
//  SequreSDK
//
//  Created by admin on 18/09/24.
//

import SwiftUI

/// use this component for default loading page
struct ScanLoadingComponent: View {
    var body: some View {
        VStack {
            (UIScreen.main.bounds.height * 0.2).verticalSpace
            GifImageView(.loadGif)
                .frame(width: 208, height: 208)
            20.verticalSpace
            Text("Processing your QR...")
                .customFont(.medium, 18)
            12.verticalSpace
            Text("Hold tight while we process your QR")
                .customFont(.regular, 16)
                .foregroundColor(.color808095)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}
