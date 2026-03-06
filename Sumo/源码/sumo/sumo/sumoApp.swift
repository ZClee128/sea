//
//  sumoApp.swift
//  sumo
//
//  Created by zclee on 2026/3/6.
//

import SwiftUI

@main
@available(iOS 15.0, *)
struct sumoApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var cacheManager = CacheManager()
    
    var body: some Scene {
        WindowGroup {
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
