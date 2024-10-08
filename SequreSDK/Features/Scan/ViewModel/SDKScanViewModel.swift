//
//  SwiftUIView.swift
//  SequreSDK
//
//  Created by admin on 12/09/24.
//

import AVFoundation
import SwiftUI
import Combine

public class SDKScanViewModel: ObservableObject {
    static let shared = SDKScanViewModel()

    @Published var statusDialog: StatusDialogScan? = nil

    private let repository = ScanUploadRepository()

    // Function to upload the image and process the response
    func uploadImage(imageFile: URL, onPostExecuted: @escaping () -> Void, onCompleted: @escaping (StatusDialogScan) -> Void) {
        onCompleted(.loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: onPostExecuted)
        repository.uploadImage(imageFile: imageFile) { [weak self] response, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let response = response {
                    self.handleScanModelResponse(response) { result in
                        onCompleted(result)
                    }
                } else {
                    self.statusDialog = .qrUndetected
                    onCompleted(self.statusDialog!)
                }
            }
        }
    }

    // Logic to handle the response
    private func handleScanModelResponse(_ response: ScanModel, onResult: @escaping (StatusDialogScan) -> Void) {
        if let classification = response.classification,
           let object = response.object,
           let score = object.score,
           let isFake = classification.label
        {
            if score < 0.5 {
                statusDialog = .qrUnreadable
            } else if isFake == "fake" {
                statusDialog = .qrUnmatch
            } else if response.qrcode?.text == nil || response.qrcode?.text?.isEmpty == true {
                statusDialog = .qrUnrecognized
            } else {
                statusDialog = .authenticated
            }
        } else {
            statusDialog = .qrUndetected
        }

        onResult(statusDialog!)
    }
}
