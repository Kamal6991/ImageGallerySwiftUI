import SwiftUI

struct ImageDetailView: View {
    let viewModel: ImageGalleryViewModel
    @State private var currentIndex: Int
    @State private var image: UIImage? = nil
    @State private var offset: CGSize = .zero // Offset for swipe animation
    @State private var scale: CGFloat = 1.0 // Scale for zooming
    @State private var showHint: Bool = true // Control the display of the hint
    private let placeholderImage = UIImage(named: Photo.placeholderImageName) // Placeholder image
    
    // Initializer to pass the starting photo and its index
    init(photo: Photo, index: Int, viewModel: ImageGalleryViewModel) {
        self.viewModel = viewModel
        self._currentIndex = State(initialValue: index)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Top-left corner title
            Text(viewModel.photos[currentIndex].title)
                .font(.headline)
                .padding(.leading)
                .padding(.top)
            
            // Image with zoom and swipe functionality
            GeometryReader { geometry in
                VStack {
                    if let image = image {
                        // Navigate to ZoomableImageView when tapping on the image
                        NavigationLink(destination: ZoomableImageView(image: image)) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale) // Apply zoom scale
                                .offset(x: offset.width, y: 0) // Apply swipe offset
                                .gesture(zoomGesture().simultaneously(with: swipeGesture())) // Combine gestures
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.7) // Adjust image size
                        }
                    } else {
                        // Placeholder with loading indicator in the center
                        ZStack {
                            Image(uiImage: placeholderImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                            ProgressView().frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                        }
                    }
                    
                    // Show hint for zoom and swipe functionality
                    if showHint {
                        Text("Tap to zoom, swipe to navigate")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding()
                            .onAppear {
                                // Automatically hide the hint after a few seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showHint = false
                                }
                            }
                    }
                }
            }
        }
        .onAppear {
            loadImage(for: viewModel.photos[currentIndex].url)
        }
        .navigationTitle("Image Detail")
        .navigationBarTitleDisplayMode(.inline) // Keep the title in the navigation bar
    }
    
    // Load the image for the current photo's URL
    private func loadImage(for urlString: String) {
        if let url = URL(string: urlString) {
            viewModel.loadImage(for: url) { loadedImage in
                withAnimation {
                    self.image = loadedImage ?? placeholderImage // If no image, use placeholder
                }
                self.offset = .zero // Reset swipe offset after the image is loaded
                self.scale = 1.0 // Reset zoom scale
            }
        }
    }
    
    // Move to the next image, if it exists
    private func nextImage() {
        guard currentIndex < viewModel.photos.count - 1 else { return }
        
        withAnimation {
            offset = CGSize(width: -UIScreen.main.bounds.width, height: 0) // Swipe left animation
        }
        
        // Immediately set the placeholder image while the next image is loading
        self.image = placeholderImage
        
        // Load the next image after swipe
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentIndex += 1
            loadImage(for: viewModel.photos[currentIndex].url)
        }
    }
    
    // Move to the previous image, if it exists
    private func previousImage() {
        guard currentIndex > 0 else { return }
        
        withAnimation {
            offset = CGSize(width: UIScreen.main.bounds.width, height: 0) // Swipe right animation
        }
        
        // Immediately set the placeholder image while the previous image is loading
        self.image = placeholderImage
        
        // Load the previous image after swipe
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentIndex -= 1
            loadImage(for: viewModel.photos[currentIndex].url)
        }
    }
    
    // Swipe gesture for navigating between images
    private func swipeGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation // Update the offset based on drag
            }
            .onEnded { value in
                if value.translation.width < -100 {
                    nextImage() // Go to next image on left swipe
                } else if value.translation.width > 100 {
                    previousImage() // Go to previous image on right swipe
                } else {
                    offset = .zero // Reset if the swipe is not long enough
                }
            }
    }
    
    // Zoom gesture for pinch-to-zoom functionality
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = value // Update the scale based on pinch gesture
            }
            .onEnded { _ in
                if scale < 1.0 {
                    scale = 1.0 // Reset scale if zoomed out too much
                }
            }
    }
}
 
