import AVFoundation
import Combine
import AudioToolbox

// MARK: - AudioManager (单例，全局共享)

@MainActor
class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {

    static let shared = AudioManager()

    // 播放状态（SwiftUI 订阅）
    @Published var isPlaying: Bool = false
    @Published var currentTrackIndex: Int = 0
    @Published var volume: Float = 0.7

    private var player: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    // 氛围音列表 (Studio Ambience)
    let tracks: [(name: String, file: String, icon: String)] = [
        ("Deep Focus",   "ambient_focus",  "waveform.circle.fill")
    ]

    var currentTrackName: String { tracks[currentTrackIndex].name }
    var currentTrackIcon: String { tracks[currentTrackIndex].icon }

    private override init() {
        super.init()
    }

    // MARK: - Session Setup

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("[AudioManager] Studio Audio Session activated.")
        } catch {
            print("[AudioManager] Session setup failed: \(error)")
        }
    }

    // MARK: - Playback Controls (Ambience) - 重命名避免冲突

    func audioPlay(trackIndex: Int? = nil) {
        if let idx = trackIndex { currentTrackIndex = idx }
        let fileName = tracks[currentTrackIndex].file

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("⚠️ [AudioManager] Ambience file missing: \(fileName).mp3")
            setupAudioSession()
            isPlaying = true
            return
        }

        setupAudioSession()
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.volume = volume
            player?.numberOfLoops = -1
            if player?.prepareToPlay() == true {
                player?.play()
                isPlaying = true
                print("[AudioManager] Ambience started: \(fileName)")
            }
        } catch {
            print("[AudioManager] Playback error: \(error)")
        }
    }

    func audioPause() {
        player?.pause()
        isPlaying = false
    }

    func audioToggle() {
        if isPlaying { audioPause() } else { audioPlay() }
    }

    func audioNext() {
        currentTrackIndex = (currentTrackIndex + 1) % tracks.count
        if isPlaying { audioPlay() }
    }

    func audioPrevious() {
        currentTrackIndex = (currentTrackIndex - 1 + tracks.count) % tracks.count
        if isPlaying { audioPlay() }
    }

    func audioSetVolume(_ v: Float) {
        volume = v
        player?.volume = v
    }

    // MARK: - Interactive SFX
    
    func playSuccessChime() {
        guard let url = Bundle.main.url(forResource: "gen_success", withExtension: "mp3") else {
            print("⚠️ [AudioManager] Success chime missing: gen_success.mp3")
            return
        }
        
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = 0.8
            sfxPlayer?.play()
            print("[AudioManager] Played success chime.")
        } catch {
            print("[AudioManager] SFX Error: \(error)")
        }
    }

    // MARK: - Debug/Test Tool
    
    func playTestSound() {
        print("[AudioManager] Testing Audio System...")
        setupAudioSession()
        AudioServicesPlaySystemSound(1000)
    }

    // MARK: - AVAudioPlayerDelegate
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            Task { @MainActor in
                AudioManager.shared.audioNext()
            }
        }
    }
}
