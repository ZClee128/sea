import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @EnvironmentObject var dataStore: MuseDataStore
    @State private var showShop = false
    @State private var showExpertList = false
    @State private var showPrivacy = false
    @State private var privacyContent = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    // Wallet Section
                    Section(header: Text("WALLET").foregroundColor(.gray)) {
                        Button(action: { showShop = true }) {
                            HStack {
                                Label("My Balance", systemImage: "sparkles")
                                    .foregroundColor(.yellow)
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("\(dataStore.coinBalance)")
                                        .bold()
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    // NEW: Professional Consult Section
                    Section(header: Text("PROFESSIONAL").foregroundColor(.gray)) {
                        Button(action: { showExpertList = true }) {
                            Label("1v1 Professional Consult", systemImage: "person.2.wave.2.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Section(header: Text("Personal").foregroundColor(.gray)) {
                        NavigationLink(destination: SavedMusesView()) {
                            Label("My Collection", systemImage: "heart.fill")
                                .foregroundColor(.pink)
                        }
                        
                        Toggle(isOn: Binding(
                            get: { dataStore.isBackgroundPlayEnabled },
                            set: { dataStore.updateBackgroundPlay($0) }
                        )) {
                            Label("Background Playback", systemImage: "play.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Information").foregroundColor(.gray)) {
                        Button(action: { 
                            loadPrivacy()
                            showPrivacy = true 
                        }) {
                            HStack {
                                Label("Privacy Policy", systemImage: "doc.text.fill")
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            Label("App Version", systemImage: "info.circle.fill")
                            Spacer()
                            Text("1.0.0").foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Management").foregroundColor(.gray)) {
                        Button(action: {
                            // Clear cache logic
                        }) {
                            Label("Clear Cache", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section {
                        VStack(alignment: .center, spacing: 8) {
                            Text("Dazzl")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            Text("Pure Aesthetic Inspiration")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPrivacy) {
                PrivacyDetailView(content: privacyContent)
            }
            .sheet(isPresented: $showShop) {
                CoinShopView()
            }
            .sheet(isPresented: $showExpertList) {
                ExpertListView()
            }
        }
        .onAppear {
            // Fix list background
            UITableView.appearance().backgroundColor = .clear
        }
    }
    
    private func loadPrivacy() {
        if let path = Bundle.main.path(forResource: "Privacy", ofType: "txt"),
           let content = try? String(contentsOfFile: path), !content.isEmpty {
            self.privacyContent = content
        } else {
            // Fallback content in case the file is missing or empty
            self.privacyContent = """
                Privacy Policy for Dazzl
                Last Updated: March 31, 2026
                
                1. Information We Collect
                Dazzl does not collect personal identity data. All favorites and settings are stored locally on your device for your privacy.
                
                2. Data Security
                We use device-level encryption for local storage. Your data never leaves your app bundle, ensuring a high-performance offline experience.
                
                3. Third-Party Content
                Media assets (images and videos) are served directly from local bundles to avoid external tracking and ensure zero-delay playback.
                
                By using Dazzl, you agree to these terms.
                """
        }
    }
}

@available(iOS 14.0, *)
struct PrivacyDetailView: View {
    let content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    Text(content)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .preferredColorScheme(.dark)
    }
}
