import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var showCacheClearedAlert = false
    @State private var showingSafari = false
    
    var body: some View {
        NavigationView {
            Form {
                // Premium Store Section
                Section {
                    if #available(iOS 14.0, *) {
                        NavigationLink(destination: StoreView(appState: appState)) {
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 40, height: 40)
                                    if #available(iOS 14.0, *) {
                                        if #available(iOS 16.0, *) {
                                            Image(systemName: "centsign")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Premium Store")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Balance: \(appState.totalCoins) Coins")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("Get Coins")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.yellow.opacity(0.3))
                                    .foregroundColor(.orange)
                                    .cornerRadius(10)
                            }
                            .padding(.vertical, 5)
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                Section(header: Text("Account & Data")) {
                    HStack {
                        Text("Saved Favorites")
                        Spacer()
                        Text("\(appState.favoriteItems.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        appState.favoriteItems = []
                        showCacheClearedAlert = true
                    }) {
                        Text("Clear Cache & Favorites")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Legal & About")) {
                    Button(action: {
                        showingSafari = true
                    }) {
                        Text("Terms of Service & Privacy Policy")
                    }
                    
                    HStack {
                        Text("App Version")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarTitle("Settings")
            .sheet(isPresented: $showingSafari) {
                if let url = URL(string: "https://docs.qq.com/doc/DQkl2THhnZVJrS2FB") {
                    SafariView(url: url)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .alert(isPresented: $showCacheClearedAlert) {
                Alert(title: Text("Success"), message: Text("Local cache and favorites have been cleared."), dismissButton: .default(Text("OK")))
            }
        }
    }
}
