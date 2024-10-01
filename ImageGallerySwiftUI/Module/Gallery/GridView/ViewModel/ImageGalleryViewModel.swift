import SwiftUI

class ImageGalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    private let imageCache: ImageCacheProtocol
    private var currentPage: Int = 1
    private var isLastPage: Bool = false
    
    init(networkService: NetworkServiceProtocol = NetworkService(),
        imageCache: ImageCacheProtocol = ImageCache()) {
        self.networkService = networkService
        self.imageCache = imageCache
        fetchPhotos() // Load initial data
    }
    
    func fetchPhotos() {
        guard !isLoading && !isLastPage else { return }
        
        isLoading = true
        networkService.fetchPhotos { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let photos):
                    let newPhotos = Array(photos.prefix(20 * self!.currentPage))
                    self?.photos = newPhotos
                    
                    if newPhotos.count == photos.count {
                        self?.isLastPage = true
                    } else {
                        self?.currentPage += 1
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadMorePhotosIfNeeded(currentItem photo: Photo) {
        if let lastPhoto = photos.last, lastPhoto.id == photo.id {
            fetchPhotos()
        }
    }
    func loadImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.getImage(for: url) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            self?.imageCache.saveImage(image, for: url)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
