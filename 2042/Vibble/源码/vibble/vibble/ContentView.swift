//
//  ContentView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        ZStack {
            // 背景层，用于捕获全局点击以收起键盘
            Color.black.edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
            Group {
                if authManager.isLoggedIn {
                    MainTabView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                } else {
                    LoginView()
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
                }
            }
        }
        .animation(.spring(), value: authManager.isLoggedIn)
        .preferredColorScheme(.dark)
    }
}
