
//
//  NetworkSevices.swift
//  NetworkWithOutPackages
//
//  Created by admin on 08/10/24.
//

import Foundation

class NetworkingService {
    static let shared = NetworkingService()

    /// File upload function using URLSession
    func uploadFile<T: Decodable>(
        url: String, fileURL: URL, fileName: String, mimeType: String, responseType: T.Type, completion: @escaping (T?, Error?) -> Void
    ) {
        // Create the URL object
        guard let uploadURL = URL(string: url) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        // Create a URLRequest object
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create the multipart form body
        var body = Data()

        // Add the file to the multipart form body
        let fileData = try? Data(contentsOf: fileURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        if let fileData = fileData {
            body.append(fileData)
        }
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Set the body to the request
        request.httpBody = body

        // Create the upload task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error as NSError? {
                // Check for common network errors
                switch error.code {
                case NSURLErrorNotConnectedToInternet:
                    completion(nil, NSError(domain: "NetworkError", code: error.code, userInfo: [NSLocalizedDescriptionKey: "No internet connection."]))
                case NSURLErrorTimedOut:
                    completion(nil, NSError(domain: "NetworkError", code: error.code, userInfo: [NSLocalizedDescriptionKey: "The request timed out."]))
                case NSURLErrorCannotConnectToHost:
                    completion(nil, NSError(domain: "NetworkError", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Cannot connect to the host."]))
                default:
                    completion(nil, error) // Handle other errors normally
                }
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            // Decode the response using the provided type
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(decodedResponse, nil)
            } catch {
                completion(nil, error)
            }
        }

        // Start the upload task
        task.resume()
    }
}
