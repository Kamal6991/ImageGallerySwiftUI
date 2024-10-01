//
//  Photo.swift
//  ImageGallerySwiftUI
//
//  Created by Office on 29/09/24.
//


import Foundation

struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
