//
//  UIImageView+AsyncLoad.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL?) {
        guard let url = url else {
            image = nil
            return
        }
        
        // Handle local file loading (relative path or absolute path)
        if url.scheme == nil || url.isFileURL {
            let fileManager = FileManager.default
            var targetURL = url
            
            // If it's just a filename (no slash), assume Documents directory
            if !url.path.contains("/") {
                let documentsPoints = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                targetURL = documentsPoints.appendingPathComponent(url.path)
            }
            
            // If file exists, load it
            if fileManager.fileExists(atPath: targetURL.path) {
                if let data = try? Data(contentsOf: targetURL), let localImage = UIImage(data: data) {
                    self.image = localImage
                    return
                }
            } else if url.absoluteString.hasPrefix("file://") {
                // Fallback: If absolute path fails (common in Simulator due to container UUID change), try resolving filename relative to current Documents
                let filename = url.lastPathComponent
                let documentsPoints = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fallbackURL = documentsPoints.appendingPathComponent(filename)
                
                if fileManager.fileExists(atPath: fallbackURL.path) {
                    if let data = try? Data(contentsOf: fallbackURL), let localImage = UIImage(data: data) {
                        self.image = localImage
                        return
                    }
                }
            }
        }
        
        // Remote loading
        // Cancel any existing download (simple approach)
        self.image = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
