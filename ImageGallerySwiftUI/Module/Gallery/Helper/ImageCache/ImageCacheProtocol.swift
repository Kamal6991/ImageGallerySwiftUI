import UIKit

protocol ImageCacheProtocol {
    func getImage(for url: URL) -> UIImage?
    func saveImage(_ image: UIImage, for url: URL)
    func clearCache()
}

class ImageCache: ImageCacheProtocol {
    private var cache = NSCache<NSURL, UIImage>()
    private var accessList: [NSURL] = [] // To track usage order for LRU eviction
    private let maxCacheSize: Int
    
    // Initialize with a maximum cache size
    init(maxCacheSize: Int = 100) { // Default cache size to 100 images
        self.maxCacheSize = maxCacheSize
        cache.countLimit = maxCacheSize // NSCache can limit automatically
    }
    
    // Retrieve image and update access list
    func getImage(for url: URL) -> UIImage? {
        let nsURL = url as NSURL
        if let image = cache.object(forKey: nsURL) {
            updateAccessList(for: nsURL)
            return image
        }
        return nil
    }
    
    // Save image and manage cache size
    func saveImage(_ image: UIImage, for url: URL) {
        let nsURL = url as NSURL
        
        // Remove the oldest (least recently used) image if cache is full
        if accessList.count >= maxCacheSize {
            if let oldestURL = accessList.first {
                cache.removeObject(forKey: oldestURL)
                accessList.removeFirst()
            }
        }
        
        cache.setObject(image, forKey: nsURL)
        updateAccessList(for: nsURL)
    }
    
    // Clear the cache completely
    func clearCache() {
        cache.removeAllObjects()
        accessList.removeAll()
    }
    
    // MARK: - Private Helpers
    
    // Update access order to implement LRU cache replacement
    private func updateAccessList(for url: NSURL) {
        if let index = accessList.firstIndex(of: url) {
            accessList.remove(at: index)
        }
        accessList.append(url)
    }
}
