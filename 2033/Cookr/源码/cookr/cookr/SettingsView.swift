import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingToS = false
    @State private var showingPrivacy = false
    @State private var showingStore = false
    @State private var backgroundPlayback: Bool = UserDefaults.standard.object(forKey: "backgroundPlayback") == nil
        ? true
        : UserDefaults.standard.bool(forKey: "backgroundPlayback")
    
    @ObservedObject private var coinManager = CoinManager.shared
    @StateObject private var storeManager = StoreManager.shared

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account & Coins")) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("My Coins")
                        Spacer()
                        Text("\(coinManager.balance)")
                            .fontWeight(.bold)
                    }
                    
                    Button(action: {
                        showingStore = true
                    }) {
                        HStack {
                            Text("Top Up Coins")
                                .foregroundColor(.accentColor)
                            Spacer()
                            Image(systemName: "cart.fill")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                Section(header: Text("Video")) {
                    Toggle(isOn: $backgroundPlayback) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Background Audio Instructions")
                            Text("Listen to cooking steps and tips while the screen is off or using other apps.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: backgroundPlayback) { value in
                        UserDefaults.standard.set(value, forKey: "backgroundPlayback")
                        VideoPlaybackManager.shared.applyAudioSession(background: value)
                    }
                }

                Section(header: Text("Legal & Privacy")) {
                    Button(action: {
                        showingToS = true
                    }) {
                        HStack {
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingPrivacy = true
                    }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Cookr")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
            .sheet(isPresented: $showingStore) {
                CoinStoreView()
            }
            .sheet(isPresented: $showingToS) {
                VStack {
                    HStack {
                        Spacer()
                        Button("Close") {
                            showingToS = false
                        }
                        .padding()
                    }
                    AgreementView(isReadOnly: true, fileName: "Agreement")
                }
            }
            .sheet(isPresented: Binding(
                get: { showingPrivacy },
                set: { showingPrivacy = $0 }
            )) {
                VStack {
                    HStack {
                        Spacer()
                        Button("Close") {
                            showingPrivacy = false
                        }
                        .padding()
                    }
                    AgreementView(isReadOnly: true, fileName: "Privacy")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            SettingsView()
        } else {
            // Fallback on earlier versions
        }
    }
}
