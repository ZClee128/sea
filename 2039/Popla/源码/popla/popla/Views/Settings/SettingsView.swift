import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var collectionManager = CollectionManager.shared
    @State private var showingPrivacy = false
    @State private var showingStore = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                List {
                    Section(header: Text("CURATION ECONOMY").font(.caption).foregroundColor(.gray)) {
                        Button(action: { showingStore = true }) {
                            HStack {
                                Image(systemName: "banknote.fill")
                                    .foregroundColor(.yellow)
                                Text("Popla Coin Store")
                                Spacer()
                                Text("\(collectionManager.coinBalance) COINS")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                        }
                    }
                    
                    Section(header: Text("EXPERIENCE").font(.caption).foregroundColor(.gray)) {
                        Toggle(isOn: $appSettings.isBackgroundPlaybackEnabled) {
                            HStack(spacing: 15) {
                                Image(systemName: "waveform.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.black)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Background Audio").font(.system(size: 15, weight: .bold))
                                    Text("Keep listening when screen is locked").font(.system(size: 11)).foregroundColor(.secondary)
                                }
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                    }
                    
                    Section(header: Text("APPLICATION").font(.caption).foregroundColor(.gray)) {
                        
                        Section(header: Text("LEGAL").font(.caption).foregroundColor(.gray)) {
                            Button(action: { showingPrivacy = true }) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundColor(.purple)
                                    Text("Privacy Policy")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.3))
                                }
                            }
                        }
                        
                        Section(header: Text("CACHE").font(.caption).foregroundColor(.gray)) {
                            Button(action: {
                                // Logic to clear local cache
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                    Text("Clear Gallery Cache")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
                .navigationBarTitle("Settings")
                .sheet(isPresented: $showingPrivacy) {
                    PrivacyPolicyModal()
                }
                .fullScreenCover(isPresented: $showingStore) {
                    if #available(iOS 15.0, *) {
                        PoplaStoreView()
                    }
                }
            }
        }
    }
}

struct PrivacyPolicyModal: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var privacyManager: PrivacyManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(privacyManager.getPrivacyContent())
                    .font(.footnote)
                    .padding()
                    .foregroundColor(.black.opacity(0.7))
            }
            .navigationBarTitle(Text("Privacy Policy"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            SettingsView()
        } else {
            // Fallback on earlier versions
        }
    }
}
