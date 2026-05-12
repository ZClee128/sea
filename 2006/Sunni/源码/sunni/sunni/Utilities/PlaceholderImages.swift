//
//  PlaceholderImages.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

// Extension to provide placeholder images for development
extension Image {
    init(_ imageName: String) {
        // For demo purposes, use SF Symbols as placeholders
        // In production, these would be actual image names from Assets.xcassets
        if imageName.contains("mountain") || imageName.contains("lake") || imageName.contains("desert") {
            self.init(systemName: "photo")
        } else if imageName.contains("video") || imageName.contains("ocean") || imageName.contains("stream") {
            self.init(systemName: "video")
        } else {
            self.init(systemName: "photo")
        }
    }
}
