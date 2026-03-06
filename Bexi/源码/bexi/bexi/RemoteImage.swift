import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let urlString: String
    private var cancellable: AnyCancellable?

    init(urlString: String) {
        self.urlString = urlString
        load()
    }

    private func load() {
        // If it's a raw filename saved by the user (no scheme), reconstruct the URL dynamically
        // because iOS changes the Documents Directory UUID on every app launch.
        if !urlString.hasPrefix("http") && !urlString.hasPrefix("file://") {
            let fileManager = FileManager.default
            if let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let localURL = docsDir.appendingPathComponent(urlString)
                loadLocalFile(url: localURL)
                return
            }
        }
        
        guard let url = URL(string: urlString) else { return }
        
        // Handle legacy saved absolute file URLs by extracting the filename
        // and aggressively reconstructing the path using the current sandbox directory.
        if url.isFileURL {
            let filename = url.lastPathComponent
            let fileManager = FileManager.default
            if let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let freshLocalURL = docsDir.appendingPathComponent(filename)
                loadLocalFile(url: freshLocalURL)
            }
            return
        }
        
        // Handle remote URLs
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    private func loadLocalFile(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct RemoteImage: View {
    @ObservedObject private var loader: ImageLoader
    let localImage: UIImage?
    
    init(urlString: String) {
        if let image = UIImage(named: urlString) {
            self.localImage = image
            _loader = ObservedObject(wrappedValue: ImageLoader(urlString: "")) // Dummy loader
        } else {
            self.localImage = nil
            _loader = ObservedObject(wrappedValue: ImageLoader(urlString: urlString))
        }
    }
    
    var body: some View {
        Group {
            if let localImg = localImage {
                Image(uiImage: localImg)
                    .resizable()
            } else if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        ActivityIndicator()
                    )
            }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

// Ensure ProgressView is available for older versions if needed, though ProgressView is iOS 14.
// For strict iOS 13, we can create a custom ActivityIndicator.
struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

extension RemoteImage {
    // Redefining body to strictly support iOS 13 using custom ActivityIndicator just in case
    var ios13Body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        ActivityIndicator()
                    )
            }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}
