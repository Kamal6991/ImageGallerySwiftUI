import SwiftUI

struct ImageGridView: View {
    @ObservedObject var viewModel: ImageGalleryViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.photos.indices, id: \.self) { index in
                        let photo = viewModel.photos[index]
                        
                        // Pass the selected photo and index to the detail view
                        NavigationLink(destination: ImageDetailView(photo: photo, index: index, viewModel: viewModel)) {
                            ImageCell(photo: photo, viewModel: viewModel)
                        }
                        .onAppear {
                            // Trigger pagination by loading more photos if necessary
                            viewModel.loadMorePhotosIfNeeded(currentItem: photo)
                        }
                    }
                    
                    // Show a progress indicator when loading more images
                    if viewModel.isLoading {
                        ProgressView("Loading more...")
                    }
                }
                .padding()
            }
            .navigationTitle("Image Gallery")
        }
    }
}
