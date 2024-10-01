import Foundation

struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
    static let placeholderImageName = "placeholder"
}
