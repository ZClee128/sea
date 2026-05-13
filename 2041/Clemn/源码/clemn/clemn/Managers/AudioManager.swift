import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    init() {}
    
    @Published var isPlaying = false
    @Published var currentTrackName: String?
    
    private var player: AVAudioPlayer?
    
    func playTrack(name: String, fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file \(fileName) not found")
            // For demo purposes, we'll pretend it's playing
            self.currentTrackName = name
            self.isPlaying = true
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop infinitely
            player?.play()
            self.currentTrackName = name
            self.isPlaying = true
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            // If nothing is selected, default to the first one
            if currentTrackName == nil {
                playTrack(name: "Professional Studio", fileName: "studio")
            } else {
                if player != nil {
                    player?.play()
                }
                isPlaying = true
            }
        }
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentTrackName = nil
    }
}
