//
//  NetworkClientProtocol.swift
//  ImageGallerySwiftUI
//
//  Created by Office on 29/09/24.
//


import Foundation

protocol NetworkClientProtocol {
    func request<T: Codable>(url: URL, completion: @escaping (Result<T, Error>) -> Void)
}

class NetworkClient: NetworkClientProtocol {
    
    // Generic request function to fetch data from the network
    func request<T: Codable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 1, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
}
