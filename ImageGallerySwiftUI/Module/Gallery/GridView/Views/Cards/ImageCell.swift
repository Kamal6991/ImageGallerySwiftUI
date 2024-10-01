import SwiftUI

struct ImageCell: View {
    let photo: Photo
    @ObservedObject var viewModel: ImageGalleryViewModel
    
    @State private var image: UIImage? = nil
    private let placeholderImage = UIImage(named: Photo.placeholderImageName)
    
    var body: some View {
        ZStack {
            // Show placeholder image while loading
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            } else {
                Image(uiImage: placeholderImage!) // Show placeholder image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                ProgressView().frame(width: 100, height: 100) // Optional loading indicator
            }
        }
        .onAppear {
            if let url = URL(string: photo.thumbnailUrl) {
                viewModel.loadImage(for: url) { loadedImage in
                    self.image = loadedImage
                }
            }
        }
    }
}

