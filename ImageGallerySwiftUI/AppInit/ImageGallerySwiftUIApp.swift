import SwiftUI

@main
struct ImageGalleryApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = ImageGalleryViewModel()
            ImageGridView(viewModel: viewModel)
        }
    }
}
