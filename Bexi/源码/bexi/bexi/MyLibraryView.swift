import SwiftUI

@available(iOS 14.0, *)
struct MyLibraryView: View {
    @EnvironmentObject var storageManager: StorageManager
    @State private var isMoodboardGenPresented = false
    @State private var showingEmptyAlert = false
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                if storageManager.savedItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Your library is empty.")
                            .foregroundColor(.secondary)
                        Text("Discover and like items to see them here.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        // For iOS 13 compatibility, LazyVGrid is iOS 14.
                        // We will use a standard wrapping HStack/VStack logic for iOS 13.
                        // Let's implement a simple grid layout logic for older iOS.
                        VStack(spacing: 10) {
                            ForEach(chunked(items: storageManager.savedItems, into: 3), id: \.self.description) { chunk in
                                HStack(spacing: 10) {
                                    ForEach(chunk) { item in
                                        RemoteImage(urlString: item.urlString)
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                    // Fill empty slots in a chunk
                                    if chunk.count < 3 {
                                        ForEach(0..<(3 - chunk.count), id: \.self) { _ in
                                            Color.clear.frame(minWidth: 0, maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("My Library")
            .navigationBarItems(trailing: 
                Button(action: {
                    if storageManager.savedItems.isEmpty {
                        showingEmptyAlert = true
                    } else {
                        isMoodboardGenPresented = true
                    }
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .imageScale(.large)
                }
            )
            .alert(isPresented: $showingEmptyAlert) {
                Alert(
                    title: Text("Library Empty"),
                    message: Text("Please save some images from Daily or Discover before creating a Moodboard."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isMoodboardGenPresented) {
                // Future Moodboard Generator View
                MoodboardGeneratorView()
                    .environmentObject(storageManager)
            }
        }
    }
    
    private func chunked(items: [MediaItem], into size: Int) -> [[MediaItem]] {
        stride(from: 0, to: items.count, by: size).map {
            Array(items[$0 ..< Swift.min($0 + size, items.count)])
        }
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        MyLibraryView()
            .environmentObject(StorageManager())
    } else {
        // Fallback on earlier versions
    }
}
