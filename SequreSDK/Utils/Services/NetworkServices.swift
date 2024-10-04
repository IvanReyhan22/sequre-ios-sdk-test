//
//  NetworkServices.swift
//  Sequre
//
//  Created by admin on 18/09/24.
//

import Alamofire
import Foundation

class NetworkingService {
    static let shared = NetworkingService()

    /// Generic request function using responseDecodable
    func request<T: Decodable>(from url: String, method: HTTPMethod, responseType: T.Type, completion: @escaping (T?, Error?) -> Void) {
        AF.request(url, method: method).validate().responseDecodable(of: responseType) { response in
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    /// File upload function using responseDecodable
    func uploadFile<T: Decodable>(url: String, fileURL: URL, fileName: String, mimeType: String, responseType: T.Type, completion: @escaping (T?, Error?) -> Void) {
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: fileName, fileName: "\(fileURL.lastPathComponent).\(fileURL.pathExtension)", mimeType: mimeType)
        }, to: url)
            .validate()
            .responseDecodable(of: responseType) { response in
                switch response.result {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
}
