import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PostDetailView: View {
    let post: Post
    @State private var isFavorite: Bool = false
    @State private var showShareSheet = false
    @State private var showingGiftAlert = false
    @State private var giftMessage = ""
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var iap = IAPManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Color.clear
                    .frame(height: 240)
                    .overlay(
                        Image(post.title)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.category.rawValue.uppercased())
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(post.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                        Text(post.author)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        
                        NavigationLink(destination: ChatView(authorName: post.author)) {
                            HStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                Text("Chat")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Text(post.content)
                        .font(.system(size: 17 * settings.fontSizeMultiplier))
                        .foregroundColor(Color(UIColor.darkGray))
                        .lineSpacing(6)
                    
                    Divider().padding(.vertical, 8)
                    
                    if let exactVideoUrl = getVideoURL() {
                        Text("Featured Video")
                            .font(.headline)
                        
                        VideoPlayerView(url: exactVideoUrl)
                            .frame(height: 220)
                            .cornerRadius(12)
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    // Gifting System (Coin Economy)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support Content Creator")
                            .font(.headline)
                        Text("Reward \(post.author) by sending virtual gifts.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            GiftButton(icon: "cup.and.saucer.fill", name: "Coffee", cost: 10) { sendGift(cost: 10, name: "Coffee") }
                            GiftButton(icon: "sparkles", name: "Magic", cost: 50) { sendGift(cost: 50, name: "Magic") }
                            GiftButton(icon: "crown.fill", name: "Crown", cost: 500) { sendGift(cost: 500, name: "Crown") }
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)
                    
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: HStack(spacing: 20) {
            Button(action: { showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.black)
            }
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isFavorite ? .red : .black)
            }
        })
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [post.title])
        }
        .alert(isPresented: $showingGiftAlert) {
            Alert(title: Text("Virtual Gift"), message: Text(giftMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadFavoriteStatus()
            trackHistory()
        }
    }
    
    func toggleFavorite() {
        var favs = UserDefaults.standard.stringArray(forKey: "FavoritePosts") ?? []
        if isFavorite {
            favs.removeAll { $0 == post.id }
        } else {
            favs.append(post.id)
        }
        UserDefaults.standard.set(favs, forKey: "FavoritePosts")
        isFavorite.toggle()
    }
    
    func loadFavoriteStatus() {
        let favs = UserDefaults.standard.stringArray(forKey: "FavoritePosts") ?? []
        isFavorite = favs.contains(post.id)
    }
    
    func trackHistory() {
        var history = UserDefaults.standard.stringArray(forKey: "HistoryPosts") ?? []
        history.removeAll { $0 == post.id }
        history.insert(post.id, at: 0)
        if history.count > 20 { history = Array(history.prefix(20)) }
        UserDefaults.standard.set(history, forKey: "HistoryPosts")
    }
    
    func getVideoURL() -> URL? {
        if let url = Bundle.main.url(forResource: post.title, withExtension: "mp4") { return url }
        if let url = Bundle.main.url(forResource: post.title, withExtension: "mov") { return url }
        if let urlStr = post.videoURLString, let url = URL(string: urlStr) { return url }
        return nil
    }
    
    func sendGift(cost: Int, name: String) {
        if iap.coins >= cost {
            iap.coins -= cost
            giftMessage = "You successfully sent a \(name) to \(post.author)! (-\(cost) Coins)"
            showingGiftAlert = true
        } else {
            giftMessage = "Not enough coins! You need \(cost) coins to send a \(name). Please visit the Store in Settings."
            showingGiftAlert = true
        }
    }
}

struct GiftButton: View {
    let icon: String
    let name: String
    let cost: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                    .padding(.bottom, 2)
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(cost)")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(width: 80, height: 80)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
}
