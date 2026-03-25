import SwiftUI
import WebKit

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @ObservedObject var coinManager = CoinManager.shared
    @State private var notificationsEnabled = true
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showCoinStore = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.99, green: 0.98, blue: 0.96)
                    .edgesIgnoringSafeArea(.bottom)
                
                List {
                    // App信息
                    Section {
                        HStack(spacing: 16) {
                            // App图标
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.4), Color(red: 1.0, green: 0.6, blue: 0.2)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sunny")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Version 1.0.0")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // 账户与钱包
                    Section(header: Text("Account")) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                .font(.system(size: 20))
                            Text("My Coins")
                            Spacer()
                            Text("\(CoinManager.shared.balance)")
                                .fontWeight(.bold)
                            
                            Button(action: { showCoinStore = true }) {
                                Text("Top-up")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color(red: 1.0, green: 0.6, blue: 0.2)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading, 8)
                        }
                    }
                    
                    // 通用设置
                    Section(header: Text("General")) {
                        NavigationLink(destination: FavoritesView()) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                Text("My Favorites")
                            }
                        }
                        
                        Toggle(isOn: $settings.backgroundPlaybackEnabled) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                Text("Background Playback")
                            }
                        }
                    }
                    
                    // 关于
                    Section(header: Text("About")) {
                        Button(action: { showPrivacyPolicy = true }) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Button(action: { showTerms = true }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                        
                    }

                    // 底部
                    Section {
                        VStack(spacing: 8) {
                            Text("Made with ♥")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text("© 2026 Sunny. All rights reserved.")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Settings")
            .sheet(isPresented: $showPrivacyPolicy) {
                WebView(htmlFile: "PrivacyPolicy")
            }
            .sheet(isPresented: $showTerms) {
                WebView(htmlFile: "TermsOfService")
            }
            .sheet(isPresented: $showCoinStore) {
                if #available(iOS 15.0, *) {
                    CoinStoreView()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
