import UIKit

struct FeedItem: Codable, Equatable {
    let id: String
    let imageURL: String?
    let videoName: String?
    let hexColor: String
    let aspectRatio: CGFloat
    let title: String
    let authorName: String
    let authorAvatarHex: String
    var isLiked: Bool
    
    // EXIF / Camera Data
    let cameraModel: String
    let filmType: String
    let lens: String
    let aperture: String
    let shutterSpeed: String
    let iso: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, imageURL, videoName, hexColor, aspectRatio, title, authorName, authorAvatarHex, isLiked
        case cameraModel, filmType, lens, aperture, shutterSpeed, iso, tags
    }
    
    init(id: String, imageURL: String?, videoName: String?, hexColor: String, aspectRatio: CGFloat, title: String, authorName: String, authorAvatarHex: String, isLiked: Bool, cameraModel: String, filmType: String, lens: String, aperture: String, shutterSpeed: String, iso: String, tags: [String]) {
        self.id = id
        self.imageURL = imageURL
        self.videoName = videoName
        self.hexColor = hexColor
        self.aspectRatio = aspectRatio
        self.title = title
        self.authorName = authorName
        self.authorAvatarHex = authorAvatarHex
        self.isLiked = isLiked
        self.cameraModel = cameraModel
        self.filmType = filmType
        self.lens = lens
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.iso = iso
        self.tags = tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        videoName = try container.decodeIfPresent(String.self, forKey: .videoName) // This handles the missing key seamlessly
        hexColor = try container.decode(String.self, forKey: .hexColor)
        aspectRatio = try container.decode(CGFloat.self, forKey: .aspectRatio)
        title = try container.decode(String.self, forKey: .title)
        authorName = try container.decode(String.self, forKey: .authorName)
        authorAvatarHex = try container.decode(String.self, forKey: .authorAvatarHex)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        cameraModel = try container.decode(String.self, forKey: .cameraModel)
        filmType = try container.decode(String.self, forKey: .filmType)
        lens = try container.decode(String.self, forKey: .lens)
        aperture = try container.decode(String.self, forKey: .aperture)
        shutterSpeed = try container.decode(String.self, forKey: .shutterSpeed)
        iso = try container.decode(String.self, forKey: .iso)
        tags = try container.decode([String].self, forKey: .tags)
    }
    
    var placeholderColor: UIColor {
        return UIColor(hex: hexColor) ?? .darkGray
    }
    
    var avatarColor: UIColor {
        return UIColor(hex: authorAvatarHex) ?? .lightGray
    }
    
    static func mockData(count: Int = 20) -> [FeedItem] {
        var items: [FeedItem] = []
        // Premium muted, cinematic aesthetic colors
        let colors = ["#2C3E50", "#34495E", "#7F8C8D", "#95A5A6", "#1A1A1D", "#4E4E50", "#C3073F", "#6F2232", "#9A1750", "#5D5C61"]
        let ratios: [CGFloat] = [0.8, 1.0, 1.25, 1.33, 1.5, 1.77]
        
        let titles = ["Neon Nights in Tokyo", "Minimalist Architecture", "Vintage Portraiture", "Cinematic Street Life", "Golden Hour Silhouettes", "Moody Landscapes", "35mm Grain", "Film Simulation Test"]
        let authors = ["@lens_master", "@analog_vibes", "@street_optic", "@portrait_dept", "@cinematic_eye"]
        
        let cameras = ["Leica M6", "Contax G2", "Pentax 67", "Hasselblad 500C/M", "Nikon F3", "Canon AE-1"]
        let films = ["Kodak Portra 400", "Ilford HP5 Plus", "Cinestill 800T", "Fujifilm Superia", "Kodak Tri-X 400"]
        let lenses = ["Summicron 35mm f/2", "Planar 45mm f/2", "SMC 105mm f/2.4", "Zeiss 80mm f/2.8", "Nikkor 50mm f/1.4"]
        
        let basicTags = ["#film", "#35mm", "#mediumformat", "#streetphotography", "#portrait", "#cinematic", "#analog"]
        
        for i in 0..<count {
            let numTags = (i % 3) + 1
            var postTags: [String] = []
            for j in 0..<numTags {
                postTags.append(basicTags[(i + j) % basicTags.count])
            }
            
            var imgName = "photo_\((i % 15) + 1)"
            var vidName: String? = nil
            
            // Only assign the newly imported video to the very first item.
            if i == 0 {
                imgName = "video" // we saved video.jpeg as "video.imageset"
                vidName = "video" // The raw video file name without extension
            }
            
            var computedRatio = ratios[i % ratios.count]
            if let img = UIImage(named: imgName) {
                computedRatio = img.size.height / img.size.width
            }
            
            let apertureArray = ["1.4", "2.0", "2.8", "4.0", "5.6", "8.0"]
            let shutterArray = ["60", "125", "250", "500", "1000"]
            let isoArray = ["100", "200", "400", "800"]
            
            let item = FeedItem(
                id: "\(i)-\(UUID().uuidString)",
                imageURL: imgName,
                videoName: vidName,
                hexColor: colors[i % colors.count],
                aspectRatio: computedRatio,
                title: titles[i % titles.count] + " \(i+1)",
                authorName: authors[i % authors.count],
                authorAvatarHex: colors[(i + 1) % colors.count],
                isLiked: false,
                cameraModel: cameras[i % cameras.count],
                filmType: films[i % films.count],
                lens: lenses[i % lenses.count],
                aperture: "f/\(apertureArray[i % apertureArray.count])",
                shutterSpeed: "1/\(shutterArray[i % shutterArray.count])s",
                iso: "ISO \(isoArray[i % isoArray.count])",
                tags: Array(Set(postTags)) // unique tags
            )
            items.append(item)
        }
        return items
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}

class LocalImageCache {
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Prevent boundless memory growth
        return cache
    }()
}

extension FeedItem {
    func resolveImage() -> UIImage? {
        guard let name = imageURL, !name.isEmpty else { return nil }
        
        if let cached = LocalImageCache.shared.object(forKey: name as NSString) {
            return cached
        }
        
        if let img = UIImage(named: name) { 
            LocalImageCache.shared.setObject(img, forKey: name as NSString)
            return img 
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filename = paths[0].appendingPathComponent(name)
        if let data = try? Data(contentsOf: filename), let savedImage = UIImage(data: data) {
            LocalImageCache.shared.setObject(savedImage, forKey: name as NSString)
            return savedImage
        }
        
        return nil
    }
}
