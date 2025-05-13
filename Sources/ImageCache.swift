import SwiftUI
import Combine

// Image cache to efficiently load and store images
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Set cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func getImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        // Check if image is in cache
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // If not in cache, download it
        guard let url = URL(string: urlString) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .handleEvents(receiveOutput: { [weak self] image in
                // Cache the downloaded image
                if let image = image {
                    self?.cache.setObject(image, forKey: urlString as NSString)
                }
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// SwiftUI Image view that loads from URL with caching
struct CachedImage: View {
    let url: String
    let placeholder: Image
    
    @State private var image: UIImage?
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
    
    private func loadImage() {
        cancellable = ImageCache.shared.getImage(from: url)
            .receive(on: DispatchQueue.main)
            .sink { loadedImage in
                self.image = loadedImage
            }
    }
}