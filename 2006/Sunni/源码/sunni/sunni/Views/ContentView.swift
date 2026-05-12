//
//  ContentView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        // Always show MainTabView - authentication is checked per feature
        MainTabView()
    }
}

@available(iOS 16.0, *)
#Preview {
    ContentView()
}
