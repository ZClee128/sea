//
//  VideoManager.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import AVFoundation
import Combine

class VideoManager: ObservableObject {
    static let shared = VideoManager()
    
    @Published var isPlaying = false
    @Published var currentTrailerIndex = 0
    @Published var currentTrackProgress: Double = 0.0
    @Published var currentTrackTime = "00:00"
    @Published var trackDuration = "00:00"
    @Published var videoSize: CGSize = CGSize(width: 16, height: 9)
    @Published var volume: Float = 0.8 {
        didSet {
            player.volume = volume
        }
    }
    
    let player = AVPlayer()
    private var timeObserverToken: Any?
    
    struct DramaTrailer: Identifiable {
        let id: Int
        let title: String
        let dramaTitle: String
        let category: String
        let videoFileName: String
        let durationText: String
        let description: String
    }
    
    let trailers = [
        DramaTrailer(id: 1, title: "Official Teaser", dramaTitle: "The Double Life of My Billionaire Husband", category: "CEO Romance", videoFileName: "0519", durationText: "0:06", description: "First look at the hidden identity of the billionaire husband."),
        DramaTrailer(id: 2, title: "Action Trailer", dramaTitle: "Reborn to Reign: Revenge of the Heiress", category: "Action & Revenge", videoFileName: "0519(1)", durationText: "0:06", description: "Suspenseful teaser of the ultimate heiress payback plan."),
        DramaTrailer(id: 3, title: "Retro Promo", dramaTitle: "Love Across Time: Retrospect 1990", category: "Time Travel & Retro", videoFileName: "0519(2)", durationText: "0:06", description: "Nostalgic clips returning to the unforgettable year of 1990."),
        DramaTrailer(id: 4, title: "Fantasy Preview", dramaTitle: "The Shadow Emperor: Rise of the Fallen", category: "Urban Fantasy & Power", videoFileName: "0519(3)", durationText: "0:06", description: "Epic awakening of the mysterious Shadow Emperor."),
        DramaTrailer(id: 5, title: "Romance Clip", dramaTitle: "My Secret Billionaire Groom", category: "CEO Romance", videoFileName: "0519(4)", durationText: "0:07", description: "A warm and sweet interaction clip between the leads."),
        DramaTrailer(id: 6, title: "Vengeance Highlights", dramaTitle: "Vengeance Unbound", category: "Action & Revenge", videoFileName: "0519(5)", durationText: "0:06", description: "Breathtaking suspenseful action cuts of the revenge path."),
        DramaTrailer(id: 7, title: "Retro Teaser", dramaTitle: "Back to 1988: Rewriting Destiny", category: "Time Travel & Retro", videoFileName: "0519(6)", durationText: "0:07", description: "Inspiring vintage showcase rewriting personal family history."),
        DramaTrailer(id: 8, title: "Dragon King Special", dramaTitle: "The Dragon King's Ascent", category: "Urban Fantasy & Power", videoFileName: "0519(7)", durationText: "0:06", description: "Visual effects and action highlight of the Dragon King rising."),
        DramaTrailer(id: 9, title: "CEO Romance Teaser", dramaTitle: "The CEO's Blind Date Contract", category: "CEO Romance", videoFileName: "0519(8)", durationText: "0:08", description: "The hilariously sweet beginning of a fake romance contract."),
        DramaTrailer(id: 10, title: "Phoenix Bloodline Clip", dramaTitle: "Bloodline of the Phoenix", category: "Action & Revenge", videoFileName: "0519(9)", durationText: "0:06", description: "Dramatic highlight of the Phoenix clan heiress's final return.")
    ]
    
    private init() {
        setupAudioSession()
        loadTrailer(at: 0)
        setupTimeObserver()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    func getBundleURL(for name: String) -> URL? {
        // 1. Try finding in root bundle first
        if let url = Bundle.main.url(forResource: name, withExtension: "mp4") {
            return url
        }
        // 2. Try finding inside "video" subdirectory
        if let url = Bundle.main.url(forResource: name, withExtension: "mp4", subdirectory: "video") {
            return url
        }
        // 3. Try finding inside "melonShare/video" subdirectory
        if let url = Bundle.main.url(forResource: name, withExtension: "mp4", subdirectory: "melonShare/video") {
            return url
        }
        return nil
    }
    
    func loadTrailer(at index: Int) {
        guard index >= 0 && index < trailers.count else { return }
        currentTrailerIndex = index
        let trailer = trailers[index]
        
        if let url = getBundleURL(for: trailer.videoFileName) {
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
        } else {
            print("Video file not found: \(trailer.videoFileName)")
        }
        
        // Reset progress values
        currentTrackProgress = 0.0
        currentTrackTime = "00:00"
        trackDuration = trailer.durationText
        videoSize = CGSize(width: 16, height: 9)
        
        if isPlaying {
            player.play()
        }
    }
    
    func play() {
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func togglePlay() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func nextTrack() {
        let nextIndex = (currentTrailerIndex + 1) % trailers.count
        loadTrailer(at: nextIndex)
    }
    
    func previousTrack() {
        let prevIndex = (currentTrailerIndex - 1 + trailers.count) % trailers.count
        loadTrailer(at: prevIndex)
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            guard let currentItem = self.player.currentItem else { return }
            
            let duration = currentItem.duration
            if CMTIME_IS_INVALID(duration) || CMTIME_IS_INDEFINITE(duration) {
                return
            }
            
            let totalSeconds = duration.seconds
            let currentSeconds = time.seconds
            
            self.currentTrackProgress = totalSeconds > 0 ? (currentSeconds / totalSeconds) : 0.0
            
            // Dynamic presentation size detection
            let size = currentItem.presentationSize
            if size.width > 0 && size.height > 0 && size != self.videoSize {
                self.videoSize = size
            }
            
            // Format current track time
            let curMin = Int(currentSeconds) / 60
            let curSec = Int(currentSeconds) % 60
            self.currentTrackTime = String(format: "%02d:%02d", curMin, curSec)
            
            // Format track duration
            let durMin = Int(totalSeconds) / 60
            let durSec = Int(totalSeconds) % 60
            self.trackDuration = String(format: "%02d:%02d", durMin, durSec)
            
            // Auto skip to next trailer when video ends
            if currentSeconds >= totalSeconds - 0.5 && totalSeconds > 0 {
                self.nextTrack()
            }
        }
    }
    
    deinit {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
        }
    }
}
