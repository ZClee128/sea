//
//  RootContentView.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import SwiftUI

struct RootContentView: View {
    @State private var isPrivacyAccepted: Bool = UserDefaults.standard.bool(forKey: "privacy_accepted")
    @State private var selectedTab: Int = 0
    
    // Inject the shared data service
    @ObservedObject var dataService = DataService.shared
    
    var body: some View {
        ZStack {
            Group {
                if isPrivacyAccepted {
                    // Main application shell
                    TabView(selection: $selectedTab) {
                        // TAB 1: Workouts
                        NavigationView {
                            VideoListView()
                        }
                        .tabItem {
                            Image(systemName: "play.rectangle.fill")
                            Text("Workouts")
                        }
                        .tag(0)
                        
                        // TAB 2: Community
                        NavigationView {
                            CommunityListView()
                        }
                        .tabItem {
                            Image(systemName: "person.3.fill")
                            Text("Community")
                        }
                        .tag(1)
                        
                        // TAB 3: Trainer Chats
                        NavigationView {
                            ChatListView()
                        }
                        .tabItem {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Coaches")
                        }
                        .tag(2)
                        
                        // TAB 4: Settings Dashboard
                        NavigationView {
                            SettingsView(isPrivacyAccepted: $isPrivacyAccepted)
                        }
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Profile")
                        }
                        .tag(3)
                    }
                    .accentColor(Color(red: 1.0, green: 0.37, blue: 0.23)) // High-energy Orange Accent
                } else {
                    // Interactive Privacy Consent popup block
                    PrivacyPolicyView(isAccepted: $isPrivacyAccepted)
                        .transition(.move(edge: .bottom))
                }
            }
            
            if let target = dataService.activeModTarget {
                CustomModerationOverlay(
                    target: target,
                    onDismiss: {
                        dataService.activeModTarget = nil
                    },
                    onSubmitReport: { reason, details in
                        withAnimation {
                            dataService.reportContent(type: target.type, id: target.contentId, reason: reason, details: details)
                        }
                    },
                    onBlockUser: { username in
                        withAnimation {
                            dataService.blockUser(username: username)
                        }
                    }
                )
            }
        }
        .preferredColorScheme(.dark) // Ignore system brightness, enforce luxury Dark theme
    }
}

struct RootContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Global Keyboard Dismissal Helper
extension View {
    func endEditingOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
