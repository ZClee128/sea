import SwiftUI
import AVKit

struct MainTabView: View {
    @ObservedObject var store: AuraStore
    @ObservedObject var privacyManager: PrivacyManager
    @ObservedObject var chatManager: ChatManager
    
    var body: some View {
        TabView {
            HomeView(store: store, chatManager: chatManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            if #available(iOS 14.0, *) {
                ExploreView(store: store, chatManager: chatManager)
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Explore")
                    }
            }
            
            if #available(iOS 14.0, *) {
                ConversationsListView(store: store, chatManager: chatManager)
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Messages")
                    }
            }
            
            if #available(iOS 14.0, *) {
                AuraMatcherView(store: store)
                    .tabItem {
                        Image(systemName: "camera.filters")
                        Text("Matcher")
                    }
            }
            
            if #available(iOS 14.0, *) {
                SettingsView(privacyManager: privacyManager, auraStore: store)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            }
        }
        .accentColor(.blue)
    }
}

// MARK: - Conversations List View (Updated with Dynamic Avatars)

@available(iOS 14.0, *)
struct ConversationsListView: View {
    @ObservedObject var store: AuraStore
    @ObservedObject var chatManager: ChatManager
    
    let socialAccounts: [AuraItem] = [
        AuraItem(id: "official_mussa", title: "Official Announcements", museName: "Mussa Official", description: "Official channel for app updates and news.", crystalType: "System", rarity: "Official", imageName: "bell.fill", videoURL: nil, category: .emerald, unlockCost: 0, prompt: "", cameraSettings: "", hasVideo: false),
        AuraItem(id: "support_crystal", title: "Customer Support", museName: "Crystal Support", description: "24/7 assistance for your ethereal journey.", crystalType: "Support", rarity: "Official", imageName: "lifepreserver.fill", videoURL: nil, category: .sapphire, unlockCost: 0, prompt: "", cameraSettings: "", hasVideo: false),
        AuraItem(id: "guide_aura", title: "Aura Guide", museName: "Ritual Assistant", description: "Learn how to maximize your crystal resonance.", crystalType: "Guide", rarity: "Help", imageName: "book.closed.fill", videoURL: nil, category: .amethyst, unlockCost: 0, prompt: "", cameraSettings: "", hasVideo: false)
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Official Channels")) {
                    ForEach(socialAccounts) { account in
                        NavigationLink(destination: ChatView(muse: account, chatManager: chatManager)) {
                            ConversationRow(muse: account, chatManager: chatManager, isOfficial: true)
                        }
                    }
                }
                
                Section(header: Text("Ethereal Connections")) {
                    ForEach(store.items.prefix(3)) { muse in
                        NavigationLink(destination: ChatView(muse: muse, chatManager: chatManager)) {
                            ConversationRow(muse: muse, chatManager: chatManager, isOfficial: false)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
        }
    }
}

@available(iOS 14.0, *)
struct ConversationRow: View {
    let muse: AuraItem
    let chatManager: ChatManager
    let isOfficial: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            AvatarView(muse: muse, isOfficial: isOfficial, size: 55)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(muse.museName).font(.system(size: 17, weight: .bold))
                    if isOfficial {
                        Text("OFFICIAL").font(.system(size: 8, weight: .heavy)).padding(.horizontal, 4).padding(.vertical, 2).background(Color.blue.opacity(0.1)).foregroundColor(.blue).cornerRadius(4)
                    }
                }
                
                let lastMsg = chatManager.conversations[muse.id]?.last?.text ?? (isOfficial ? "Welcome to Mussa Official Channel." : "Start your ethereal connection...")
                Text(lastMsg).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer()
            if let lastTime = chatManager.conversations[muse.id]?.last?.timestamp {
                Text(lastTime, style: .relative).font(.caption2).foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Avatar View (Replacing Local Images)

struct AvatarView: View {
    let muse: AuraItem
    let isOfficial: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isOfficial {
                // Official style avatars using SF Symbols
                Circle()
                    .fill(officialColor.opacity(0.1))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: muse.imageName) // In socialAccounts we put SF symbol names here
                            .foregroundColor(officialColor)
                            .font(.system(size: size * 0.4, weight: .bold))
                    )
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()))
                    .font(.system(size: size * 0.25))
                    .offset(x: 2, y: 2)
            } else {
                // User/Muse style avatars using initials and vibrant gradients
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(String(muse.museName.prefix(1)))
                            .font(.system(size: size * 0.4, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Circle()
                    .fill(Color.green)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }
        }
    }
    
    private var officialColor: Color {
        switch muse.id {
        case "official_mussa": return .blue
        case "support_crystal": return .orange
        case "guide_aura": return .purple
        default: return .blue
        }
    }
}

// MARK: - Aura Matcher View (Keep original logic)

@available(iOS 14.0, *)
struct AuraMatcherView: View {
    @ObservedObject var store: AuraStore
    @State private var phase: MatchPhase = .start
    @State private var selectedEmotion: String = ""
    @State private var matchedAura: AuraItem?
    @State private var player: AVPlayer?
    @State private var isAnalyzing = false
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    @State private var showVideoFullScreen = false
    
    enum MatchPhase {
        case start, question, analyzing, result
    }
    
    let emotions = ["Calm", "Energetic", "Mysterious", "Focused", "Romantic"]
    
    var body: some View {
        VStack {
            if phase == .start {
                startView
            } else if phase == .question {
                questionView
            } else if phase == .analyzing {
                analyzingView
            } else if phase == .result {
                resultView
            }
        }
        .animation(.easeInOut, value: phase)
        .alert(isPresented: $showingSaveAlert) {
            Alert(title: Text("Notice"), message: Text(saveMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showVideoFullScreen) {
            if let player = player {
                VideoPlayerView(player: player)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    // Start Screen
    var startView: some View {
        VStack(spacing: 30) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Aura Matcher")
                .font(.system(size: 34, weight: .bold))
            
            Text("Find the Mussa that resonates with your current energy and watch your daily ritual video.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { phase = .question }) {
                Text("Begin Analysis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 250)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
        }
    }
    
    // Question Screen
    var questionView: some View {
        VStack(spacing: 40) {
            Text("How is your energy today?")
                .font(.system(size: 24, weight: .bold))
            
            VStack(spacing: 15) {
                ForEach(emotions, id: \.self) { emotion in
                    Button(action: {
                        selectedEmotion = emotion
                        startAnalysis()
                    }) {
                        Text(emotion)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
    
    // Analyzing Screen
    var analyzingView: some View {
        VStack(spacing: 30) {
            ProgressView()
                .scaleEffect(2)
            Text("Scanning Crystal Frequencies...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.blue)
        }
    }
    
    // Result Screen with Video Player
    var resultView: some View {
        ScrollView {
            VStack(spacing: 25) {
                if let aura = matchedAura {
                    Text("Your Mussa Match")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top)
                    
                    // Video/Image Preview Area
                    ZStack(alignment: .center) {
                        Image(aura.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 450)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        Text(aura.museName)
                            .font(.system(size: 24, weight: .bold))
                        Text("\(aura.crystalType) Aura • \(selectedEmotion) Soul")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    
                    Text(aura.description)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            saveToLibrary(imageName: aura.imageName)
                        }) {
                            Label("Save Ritual", systemImage: "arrow.down.circle.fill")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { reset() }) {
                            Text("Retry")
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    func startAnalysis() {
        phase = .analyzing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            matchedAura = store.items.randomElement()
            phase = .result
        }
    }
    
    func reset() {
        player?.pause()
        player = nil
        phase = .start
    }
    
    func prepareAndPlayVideo() {
        // Try local video first
        if let url = Bundle.main.url(forResource: "ritual_video", withExtension: "mp4") {
            player = AVPlayer(url: url)
            showVideoFullScreen = true
            player?.play()
        } else {
            saveMessage = "Please ensure 'ritual_video.mp4' is added to the project."
            showingSaveAlert = true
        }
    }
    
    func saveToLibrary(imageName: String) {
        guard let image = UIImage(named: imageName) else {
            saveMessage = "Error: Image not found."
            showingSaveAlert = true
            return
        }
        
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            saveMessage = "Ritual saved to your photos!"
            showingSaveAlert = true
        }
        imageSaver.errorHandler = { error in
            saveMessage = "Error saving: \(error.localizedDescription)"
            showingSaveAlert = true
        }
        imageSaver.writeToPhotoAlbum(image: image)
    }
}

// Full screen video player helper
struct VideoPlayerView: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
