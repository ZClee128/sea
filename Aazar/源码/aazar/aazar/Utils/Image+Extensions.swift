import UIKit

extension UIImageView {
    func loadImage(from url: URL, completion: ((UIImage?) -> Void)? = nil) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            DispatchQueue.main.async {
                self.image = image
                completion?(image)
            }
        }.resume()
    }
}

extension UIImage {
    func extractDominantColors() -> [UIColor] {
        var colors = [UIColor]()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Use RGBA format, premultiplied
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let w = self.size.width
        let h = self.size.height
        
        guard w > 0, h > 0, let cgImage = self.cgImage else {
            return [.systemGray, .systemGray2, .systemGray3, .systemGray4]
        }
        
        let halfW = w / 2
        let halfH = h / 2
        
        let rects = [
            CGRect(x: 0, y: 0, width: halfW, height: halfH),         // Top Left
            CGRect(x: halfW, y: 0, width: halfW, height: halfH),     // Top Right
            CGRect(x: 0, y: halfH, width: halfW, height: halfH),     // Bottom Left
            CGRect(x: halfW, y: halfH, width: halfW, height: halfH)  // Bottom Right
        ]
        
        var pixelData = [UInt8](repeating: 0, count: 4)
        
        guard let context = CGContext(data: &pixelData,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return [.systemGray, .systemGray2, .systemGray3, .systemGray4]
        }
        
        // This makes CGContext interpolation smooth, averaging the pixels in the quadrant
        context.interpolationQuality = .medium
        
        for rect in rects {
            context.clear(CGRect(x: 0, y: 0, width: 1, height: 1))
            context.saveGState()
            
            // Map the quadrant to the 1x1 context
            context.scaleBy(x: 1.0 / rect.width, y: 1.0 / rect.height)
            context.translateBy(x: -rect.minX, y: -rect.minY)
            
            // Draw original image. CGImage coordinates: origin is at bottom-left, but it doesn't matter for pure quadrant extraction
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
            
            context.restoreGState()
            
            let r = CGFloat(pixelData[0]) / 255.0
            let g = CGFloat(pixelData[1]) / 255.0
            let b = CGFloat(pixelData[2]) / 255.0
            
            // Avoid adding pure black/white/transparent unless necessary, but for simplicity, we append what we get
            colors.append(UIColor(red: r, green: g, blue: b, alpha: 1.0))
        }
        
        return colors
    }
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb).uppercased()
    }
}
