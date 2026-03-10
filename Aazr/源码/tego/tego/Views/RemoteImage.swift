//
//  RemoteImage.swift
//  tego
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var url: URL
    private var cancellable: AnyCancellable?

    init(url: URL) {
        self.url = url
    }

    func load() {
        // Simple cache
        if let cached = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            self.image = UIImage(data: cached.data)
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    func cancel() {
        cancellable?.cancel()
    }
}

struct RemoteImage: View {
    let urlString: String
    @ObservedObject private var loader: ImageLoader

    init(urlString: String) {
        self.urlString = urlString
        self._loader = ObservedObject(initialValue: ImageLoader(url: URL(string: urlString)!))
    }

    var body: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .onAppear(perform: loader.load)
        .onDisappear(perform: loader.cancel)
    }
}
