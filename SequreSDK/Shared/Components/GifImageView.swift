//
//  GifImageView.swift
//  SequreSDK
//
//  Created by admin on 18/09/24.
//

import SwiftUI
import WebKit

enum GifAssetFile: String {
    /// asset name in folder Gif-sdk-asset
    case loadGif = "loadGif"
}

/// component for displaying gif image
struct GifImageView: UIViewRepresentable {
    private let name: GifAssetFile
    
    init(_ name: GifAssetFile) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        let url = Bundle.main.url(forResource: name.rawValue, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        
        webview.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
}
