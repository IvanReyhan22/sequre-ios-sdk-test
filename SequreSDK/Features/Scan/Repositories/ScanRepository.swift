//
//  Repository.swift
//  NetworkWithOutPackages
//
//  Created by admin on 18/09/24.
//

import Combine
import Foundation

/// repository for upload qr image
public class ScanUploadRepository {
    static let shared = ScanUploadRepository()

    private let networkingService = NetworkingService.shared

    func uploadImage(imageFile: URL, completion: @escaping (ScanModel?, Error?) -> Void) {
        let url = "https://image-validation-484903075772.asia-southeast2.run.app"

        networkingService.uploadFile(
            url: url, fileURL: imageFile, fileName: "imagefile", mimeType: "image/jpeg", responseType: ScanModel.self
        ) { response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            completion(response, nil)
        }
    }
}
