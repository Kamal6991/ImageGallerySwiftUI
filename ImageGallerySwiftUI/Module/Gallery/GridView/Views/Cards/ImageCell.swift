import SwiftUI

struct ImageCell: View {
    let photo: Photo
    @ObservedObject var viewModel: ImageGalleryViewModel
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 100, height: 100)
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            } else {
                ProgressView().frame(width: 100, height: 100)
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
