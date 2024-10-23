//
//  ToastExtension.swift
//  SequreSDK
//
//  Created by admin on 23/10/24.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    let message: LocalizedStringKey
    @Binding var isShowing: Bool
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack {
            content
            if self.isShowing {
                VStack {
                    Spacer()
                    Text(self.message)
                        .font(.body)
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 60)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                                withAnimation(.easeInOut) {
                                    self.isShowing = false
                                }
                            }
                        }
                }
            }
        }
    }
}

extension View {
    func toast(_ message: LocalizedStringKey, isShowing: Binding<Bool>, duration: TimeInterval = 3) -> some View {
        self.modifier(ToastModifier(message: message, isShowing: isShowing, duration: duration))
    }
}
