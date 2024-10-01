import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1.0 // Current scale factor for the zoom
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero // Current offset for panning
    @State private var lastOffset: CGSize = .zero
    
    // Constants to control zoom and pan boundaries
    let minScale: CGFloat = 1.0
    let maxScale: CGFloat = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = imageSizeForZoom(geometry: geometry)
            
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .scaleEffect(self.scale) // Apply the zoom level
                    .offset(x: self.offset.width, y: self.offset.height) // Apply the panning offset
                    .gesture(
                        zoomGesture(for: geometry.size)
                            .simultaneously(with: panGesture(for: geometry.size))
                    )
                    .onAppear {
                        self.resetZoomAndOffset()
                    }
                    .animation(.easeInOut, value: scale) // Smooth zoom and pan transitions
            }
        }
        .navigationBarTitle("Zoom", displayMode: .inline)
    }
    
    // Function to calculate the image size based on the zoom scale and geometry size
    private func imageSizeForZoom(geometry: GeometryProxy) -> CGSize {
        let imageWidth = geometry.size.width
        let imageHeight = geometry.size.height
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    // Function to reset zoom and offset when the view appears
    private func resetZoomAndOffset() {
        self.scale = 1.0
        self.lastScale = 1.0
        self.offset = .zero
        self.lastOffset = .zero
    }
    
    // Gesture for zooming in/out
    private func zoomGesture(for size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // Calculate the new scale based on the gesture magnification value
                let newScale = self.lastScale * value
                
                // Constrain the scale between minScale and maxScale
                self.scale = min(max(self.minScale, newScale), self.maxScale)
                
                // Adjust the offset after zooming to make sure the image doesn't move offscreen
                self.offset = self.constrainOffset(self.offset, for: size)
            }
            .onEnded { _ in
                // Store the last scale for future zoom gestures
                self.lastScale = self.scale
            }
    }
    
    // Gesture for panning/moving the zoomed image
    private func panGesture(for size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Calculate the potential new offset based on drag translation
                let potentialOffset = CGSize(
                    width: self.lastOffset.width + value.translation.width,
                    height: self.lastOffset.height + value.translation.height
                )
                
                // Constrain panning within the image's visible boundaries
                self.offset = self.constrainOffset(potentialOffset, for: size)
            }
            .onEnded { _ in
                // Save the last offset for future drag gestures
                self.lastOffset = self.offset
            }
    }
    
    // Function to constrain the offset so the image doesn't move beyond the visible bounds
    private func constrainOffset(_ offset: CGSize, for size: CGSize) -> CGSize {
        // Calculate the size of the scaled image
        let imageWidth = size.width * scale
        let imageHeight = size.height * scale
        
        // Calculate the maximum allowable panning distance for each axis
        let maxX = max((imageWidth - size.width) / 2, 0)
        let maxY = max((imageHeight - size.height) / 2, 0)
        
        // Constrain the offset to prevent dragging the image out of bounds
        let constrainedX = min(max(-maxX, offset.width), maxX)
        let constrainedY = min(max(-maxY, offset.height), maxY)
        
        return CGSize(width: constrainedX, height: constrainedY)
    }
}
