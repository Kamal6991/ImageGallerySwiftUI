import Foundation

protocol NetworkServiceProtocol {
    func fetchPhotos(completion: @escaping (Result<[Photo], Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func fetchPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        networkClient.request(url: url, completion: completion)
    }
}
