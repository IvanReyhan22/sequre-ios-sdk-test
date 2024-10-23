//
//  SwiftUIView.swift
//  SequreSDK
//
//  Created by admin on 12/09/24.
//

import AVFoundation
import Combine
import SwiftUI

public class SDKScanViewModel: ObservableObject {
    public static let shared = SDKScanViewModel()

    @Published var statusDialog: StatusDialogScan? = nil

    private let repository = ScanUploadRepository()

    /// Function for validation qr before upload in server
    func checkInvalidQrImage(from imageUrl: URL) -> Bool {
        guard let imageData = try? Data(contentsOf: imageUrl),
              let uiImage = UIImage(data: imageData),
              let ciImage = CIImage(image: uiImage)
        else {
            return true
        }

        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrCodeDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
        let features = qrCodeDetector?.features(in: ciImage) ?? []

        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature, qrFeature.messageString != nil {
                print(qrFeature.messageString ?? "nil")
                return false
            }
        }

        return true
    }

    /// Function to upload the image and process the response
    func uploadImage(
        imageFile: URL,
        onPostExecuted: @escaping () -> Void,
        returnScanModel: ((ScanModel) -> Void)? = nil,
        onCompleted: @escaping (StatusDialogScan?) -> Void
    ) {
        onCompleted(.loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: onPostExecuted)
        repository.uploadImage(imageFile: imageFile) { [weak self] response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let response = response {
                    returnScanModel?(response)
                    self.handleScanModelResponse(response) { result in
                        onCompleted(result)
                    }
                } else {
                    if let nsError = error as NSError? {
                        switch nsError.domain {
                        case "NetworkError":
                            DispatchSerialQueue.main.asyncAfter(deadline: .now() + 1) {
                                onCompleted(nil)
                            }
                        default:
                            onCompleted(.qrUnrecognized)
                        }
                    } else {
                        onCompleted(.qrUnrecognized)
                    }
                }
            }
        }
    }

    /// Logic to handle the response
    private func handleScanModelResponse(_ response: ScanModel, onResult: @escaping (StatusDialogScan) -> Void) {
        if let classification = response.classification,
           let object = response.object,
           let qrCode = response.qrcode,
           let canvas = response.canvas,
           let score = classification.score,
           let label = classification.label
        {
            if score >= 0.85,
               label == "genuine",
               object.status == "detected",
               canvas.status == "detected",
               qrCode.status == "detected",
               classification.status == "detected"
            {
                statusDialog = .authenticated
            } else {
                statusDialog = .qrUnrecognized
            }
        } else {
            statusDialog = .qrUnrecognized
        }
        onResult(statusDialog!)
    }
}
