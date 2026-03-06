// sumoApp.swift
// The SwiftUI App struct is no longer the @main entry – AppDelegate (via main.swift) owns startup.
// This file just holds the Scene definition so Xcode is happy.
import SwiftUI

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
