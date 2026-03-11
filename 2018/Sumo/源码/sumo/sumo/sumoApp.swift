import SwiftUI
import AVFoundation

@available(iOS 14.0, *)
struct SumoApp: App {
    init() {
        // Configure audio session for background playback
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("[AVAudioSession] setup error: \(error)")
        }
    }

    @available(iOS 14.0, *)
    var body: some Scene {
        WindowGroup {
            if #available(iOS 15.0, *) {
                SumoRootView()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// MARK: - Root view (agreement gate → main tabs)

@available(iOS 15.0, *)
struct SumoRootView: View {
    @StateObject private var appState = AppStateManager()
    @StateObject private var cacheManager = CacheManager()

    var body: some View {
        Group {
            if appState.hasAgreedToTerms {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(cacheManager)
            } else {
                AgreementView()
                    .environmentObject(appState)
            }
        }
    }
}
