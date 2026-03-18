import SwiftUI

struct SettingsView: View {
    @State private var showingAgreement = false
    @State private var showingStore = false
    @State private var cacheCleared = false
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Account & Economy")) {
                Button(action: {
                    showingStore = true
                }) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                        Text("Coin Store")
                        Spacer()
                        Text("\(StoreManager.shared.userCoins)")
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingStore) {
                    StoreView()
                }
            }
            
            Section(header: Text("Playback Settings")) {
                Toggle(isOn: $settingsManager.enableBackgroundPlayback) {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                            .foregroundColor(.blue)
                        Text("Background Video Playback")
                    }
                }
            }
            
            Section(header: Text("App Information")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Legal")) {
                Button(action: {
                    showingAgreement = true
                }) {
                    Text("Privacy Policy")
                }
                .sheet(isPresented: $showingAgreement) {
                    AgreementView(isReadOnly: true)
                }
            }
            
            Section(header: Text("Data Management")) {
                Button(action: {
                    // Mock clearing cache
                    cacheCleared = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        cacheCleared = false
                    }
                }) {
                    HStack {
                        Text(cacheCleared ? "Cache Cleared!" : "Clear Image Cache")
                            .foregroundColor(cacheCleared ? .green : .red)
                        if cacheCleared {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
