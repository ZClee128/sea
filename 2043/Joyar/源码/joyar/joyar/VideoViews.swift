//
//  VideoViews.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import SwiftUI
import AVKit

// MARK: - Video Player Manager
class VideoPlayerManager {
    static let shared = VideoPlayerManager()
    weak var activePlayer: AVPlayer?
    
    func registerPlayer(_ player: AVPlayer) {
        activePlayer?.pause()
        activePlayer = player
    }
    
    func pauseActivePlayer() {
        activePlayer?.pause()
        activePlayer = nil
    }
}

// MARK: - Safe iOS 13 Native AVPlayer Wrapper
struct LocalVideoPlayerView: UIViewControllerRepresentable {
    let videoURL: String
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        var observerToken: Any?
        
        deinit {
            if let token = observerToken {
                NotificationCenter.default.removeObserver(token)
            }
            player?.pause()
            player = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        let url: URL?
        if videoURL.hasPrefix("http://") || videoURL.hasPrefix("https://") {
            url = URL(string: videoURL)
        } else {
            let name = videoURL.replacingOccurrences(of: ".mp4", with: "")
            url = Bundle.main.url(forResource: name, withExtension: "mp4")
        }
        
        if let playUrl = url {
            let player = AVPlayer(url: playUrl)
            context.coordinator.player = player
            controller.player = player
            player.play()
            VideoPlayerManager.shared.registerPlayer(player)
            
            // Loop video playback safely avoiding retain cycle
            context.coordinator.observerToken = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        if let token = coordinator.observerToken {
            NotificationCenter.default.removeObserver(token)
            coordinator.observerToken = nil
        }
        uiViewController.player?.pause()
        uiViewController.player = nil
        coordinator.player?.pause()
        coordinator.player = nil
    }
}


// MARK: - Dynamic First-Frame Video Thumbnail Extractor
struct VideoThumbnailView: View {
    let videoURL: String
    @State private var thumbnailImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image = thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.15, green: 0.15, blue: 0.18), Color(red: 0.10, green: 0.10, blue: 0.12)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                ActivityIndicator()
            }
        }
        .frame(height: 180)
        .clipped()
        .contentShape(Rectangle())
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        guard thumbnailImage == nil else { return }
        
        let url: URL?
        if videoURL.hasPrefix("http://") || videoURL.hasPrefix("https://") {
            url = URL(string: videoURL)
        } else {
            let name = videoURL.replacingOccurrences(of: ".mp4", with: "")
            url = Bundle.main.url(forResource: name, withExtension: "mp4")
        }
        
        guard let assetUrl = url else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: assetUrl)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0.0, preferredTimescale: 60)
            
            do {
                let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
                DispatchQueue.main.async {
                    self.thumbnailImage = image
                }
            } catch {
                print("Error generating thumbnail for \(videoURL): \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Video List View
struct VideoListView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var searchQuery = ""
    @State private var selectedCategory = "All"
    
    @State private var showUnlockAlert = false
    @State private var showLowCoinsAlert = false
    @State private var selectedVideoToUnlock: WorkoutVideo? = nil
    @State private var showStoreSheet = false
    @State private var selectedVideo: WorkoutVideo? = nil
    
    let categories = ["All", "HIIT", "Strength", "Yoga", "Cardio"]
    
    // Grid layout safe for iOS 13 (using columns of stacks)
    var filteredVideos: [WorkoutVideo] {
        dataService.workoutVideos.filter { video in
            let matchSearch = searchQuery.isEmpty || video.title.localizedCaseInsensitiveContains(searchQuery) || video.description.localizedCaseInsensitiveContains(searchQuery)
            let matchCategory = selectedCategory == "All" || video.category == selectedCategory
            return matchSearch && matchCategory
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Energetic App Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("JOYAR WORKOUTS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                .tracking(2)
                            
                            Text("Train Like A Pro")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    
                    // Search Bar View
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search workouts...", text: $searchQuery)
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                        
                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Category Slider safe for iOS 13
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = cat
                                    }
                                }) {
                                    Text(cat)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(selectedCategory == cat ? .black : .white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedCategory == cat ?
                                            AnyView(LinearGradient(
                                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.37, blue: 0.23), Color(red: 1.0, green: 0.18, blue: 0.33)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )) : AnyView(Color(red: 0.12, green: 0.12, blue: 0.14))
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Grid layout safe for iOS 13
                    VStack(spacing: 16) {
                        if filteredVideos.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "flame")
                                    .font(.system(size: 38))
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                                Text("No workouts match query")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("Try searching with another category or title keyword")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredVideos, id: \.id) { video in
                                let isLocked = video.id == "vid_masterclass" && !dataService.unlockedVideos.contains("vid_masterclass")
                                
                                if isLocked {
                                    WorkoutCardView(video: video, isLockedOverride: true)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedVideoToUnlock = video
                                            showUnlockAlert = true
                                        }
                                } else {
                                    WorkoutCardView(video: video, isLockedOverride: false)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedVideo = video
                                        }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .frame(minHeight: geometry.size.height, alignment: .top)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .background(
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
        )
        .background(
            ZStack {
                NavigationLink(
                    destination: Group {
                        if let video = selectedVideo {
                            VideoDetailView(video: video)
                        }
                    },
                    isActive: Binding(
                        get: { selectedVideo != nil },
                        set: { if !$0 { selectedVideo = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .frame(width: 0, height: 0)
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .sheet(isPresented: $showStoreSheet) {
            StoreView()
        }
        .alert(isPresented: $showUnlockAlert) {
            Alert(
                title: Text("Unlock Masterclass? 👑"),
                message: Text("Sarah Jenkins's premium 'Elite Core Shred' training requires 96 Coins to unlock permanently."),
                primaryButton: .default(Text("Unlock for 96 Coins")) {
                    if dataService.unlockVideo(videoId: "vid_masterclass", cost: 96) {
                        // Unlocked successfully!
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showLowCoinsAlert = true
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .background(
            EmptyView()
                .alert(isPresented: $showLowCoinsAlert) {
                    Alert(
                        title: Text("Insufficient Coins"),
                        message: Text("You need at least 96 Coins to unlock this masterclass program. Open the shop to top up now!"),
                        primaryButton: .default(Text("Get Coins")) {
                            showStoreSheet = true
                        },
                        secondaryButton: .cancel()
                    )
                }
        )
    }
}

// MARK: - Premium Workout Card
struct WorkoutCardView: View {
    let video: WorkoutVideo
    var isLockedOverride: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Simulated Video Thumbnail overlay
            ZStack(alignment: .topTrailing) {
                // Main Image Visual Representation
                ZStack {
                    VideoThumbnailView(videoURL: video.videoURL)
                        .frame(height: 180)
                        .clipped()
                    
                    Color.black.opacity(0.3) // Subtle overlay to maintain legibility
                    
                    VStack(spacing: 12) {
                        if isLockedOverride {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .frame(height: 180)
                
                // Badges overlay
                HStack {
                    Text(video.difficulty)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    if video.isFavorited {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(10)
            }
            
            // Course Meta info below
            VStack(alignment: .leading, spacing: 8) {
                Text(video.category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                    .tracking(1.5)
                
                Text(video.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("\(video.durationMinutes) min")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                        Text("\(video.caloriesBurned) kcal")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(video.viewCount / 1000)k plays")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Video Playback & Detail (2/3 Large Screen Player)
struct VideoDetailView: View {
    let video: WorkoutVideo
    @ObservedObject var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showCompleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. Large 2/3 Scale Stream Player Panel
                // Renders the live looping video stream from custom representable
                ZStack(alignment: .topLeading) {
                    LocalVideoPlayerView(videoURL: video.videoURL)
                        .frame(height: UIScreen.main.bounds.height * 0.60) // Premium portrait height
                        .cornerRadius(20)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                    
                    // Custom back button overlay
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(20)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header title & Heart Toggler
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(video.category.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                .tracking(2)
                            
                            Text(video.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                dataService.toggleFavorite(videoId: video.id)
                            }
                        }) {
                            Image(systemName: dataService.workoutVideos.firstNumerator(where: { $0.id == video.id })?.isFavorited ?? false ? "heart.fill" : "heart")
                                .font(.system(size: 22))
                                .foregroundColor(dataService.workoutVideos.firstNumerator(where: { $0.id == video.id })?.isFavorited ?? false ? .red : .gray)
                                .padding(12)
                                .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Calorie/Time Badges
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.gray)
                            Text("\(video.durationMinutes) Minutes")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                            Text("\(video.caloriesBurned) Calories")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "speedometer")
                                .foregroundColor(.gray)
                            Text(video.difficulty)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .cornerRadius(12)
                    
                    // Trainer row
                    HStack(spacing: 12) {
                        Image(systemName: video.trainerAvatar)
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(video.trainerName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Joyar Elite Trainer")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Workout")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(video.description)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    
                    // Training Steps Bullet list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Core Workout Guide")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        ForEach(0..<video.trainingPoints.count, id: \.self) { index in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 20, height: 20)
                                    .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                                    .clipShape(Circle())
                                
                                Text(video.trainingPoints[index])
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .lineSpacing(2)
                            }
                        }
                    }
                    
                    // Log Completion button
                    Button(action: {
                        dataService.completeWorkout(videoId: video.id)
                        showCompleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Complete Workout & Log Burn")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.37, blue: 0.23),
                                    Color(red: 1.0, green: 0.18, blue: 0.33)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(26)
                        .shadow(color: Color(red: 1.0, green: 0.18, blue: 0.33).opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.08).edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onDisappear {
            VideoPlayerManager.shared.pauseActivePlayer()
        }
        .alert(isPresented: $showCompleteAlert) {
            Alert(
                title: Text("Workout Completed! 🎉"),
                message: Text("Fantastic job! You've logged \(video.caloriesBurned) calories into your Joyar activity log. Keep up this amazing momentum!"),
                dismissButton: .default(Text("Awesome!"))
            )
        }
    }
}

struct VideoViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoListView()
        }
        .preferredColorScheme(.dark)
    }
}
