import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentSound: String?
    
    @Published var volume: Float = 0.5 {
        didSet {
            player?.volume = volume
        }
    }
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func play(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else {
            print("Sound file not found: \(sound)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Infinite loop
            player?.volume = volume
            player?.play()
            isPlaying = true
            currentSound = sound
        } catch {
            print("Could not play sound: \(error)")
        }
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentSound = nil
    }
    
    func toggle() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
}
