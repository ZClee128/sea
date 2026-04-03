import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @State private var showingLegal = false
    @State private var legalTitle = ""
    @State private var legalFileName = ""
    @State private var showingClearCacheAlert = false
    @State private var cacheSize = "1.2 MB"
    @AppStorage("isBackgroundPlaybackEnabled") var isBackgroundPlaybackEnabled = true
    @State private var showingShop = false
    @ObservedObject var personaManager = PersonaManager.shared
    @ObservedObject var storeManager = StoreManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("AESTHETIC PROFILE")) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(personaManager.currentPersona.themeColor.opacity(0.1))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: personaManager.currentPersona.icon)
                                    .foregroundColor(personaManager.currentPersona.themeColor)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(personaManager.currentPersona.rawValue)
                                .font(.system(size: 16, weight: .bold, design: .serif))
                            
                            Text(personaManager.currentPersona == .undiagnosed ? "Awaiting DNA decoding" : "Current Persona")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: AestheticIQView()) {
                            Text(personaManager.currentPersona == .undiagnosed ? "Take Test" : "Re-test")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("COIN BOUTIQUE")) {
                    HStack {
                        Image(systemName: "circle.circle.fill")
                            .foregroundColor(.yellow)
                        Text("Balance")
                            .font(.system(size: 16, design: .serif))
                        Spacer()
                        Text("\(storeManager.coinBalance) coins")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: { showingShop = true }) {
                        Label("Go to Boutique", systemImage: "cart.fill")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.black)
                    }
                }
                
                Section(header: Text("PREFERENCES")) {
                    Toggle("Background Playback", isOn: $isBackgroundPlaybackEnabled)
                        .font(.system(size: 16, design: .serif))
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Fickr")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("LEGAL & POLICY")) {
                    legalButton(title: "Privacy Policy", fileName: "PrivacyPolicy")
                    legalButton(title: "Terms of Service", fileName: "TermsOfService")
                    legalButton(title: "Community Guidelines", fileName: "CommunityGuidelines")
                }
                
                Section(header: Text("SUPPORT")) {
                    // Button(action: openSupportURL) {
                    //     HStack {
                    //         Text("Technical Support")
                    //             .foregroundColor(.black)
                    //         Spacer()
                    //         Image(systemName: "safari")
                    //             .foregroundColor(.blue)
                    //     }
                    // }
                    
                    Button(action: openFeedback) {
                        HStack {
                            Text("Email Feedback")
                                .foregroundColor(.black)
                            Spacer()
                            Text("lovantiep9088@icloud.com")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: { showingClearCacheAlert = true }) {
                        HStack {
                            Text("Clear Aesthetic Cache")
                                .foregroundColor(.black)
                            Spacer()
                            Text(cacheSize)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Text("© 2026 Fickr Aesthetic Insights")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .sheet(isPresented: $showingLegal) {
                LegalDetailView(title: legalTitle, fileName: legalFileName)
            }
            .sheet(isPresented: $showingShop) {
                CoinShopView()
            }
            .alert(isPresented: $showingClearCacheAlert) {
                Alert(
                    title: Text("Clear Cache"),
                    message: Text("Are you sure you want to clear the app's aesthetic cache?"),
                    primaryButton: .destructive(Text("Clear")) {
                        clearCache()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func legalButton(title: String, fileName: String) -> some View {
        Button(action: {
                legalTitle = title
                legalFileName = fileName
                showingLegal = true
            }) {
                HStack {
                    Text(title)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
    }

    private func openFeedback() {
        if let url = URL(string: "mailto:lovantiep9088@icloud.com?subject=Fickr%20Feedback") {
            UIApplication.shared.open(url)
        }
    }

    private func clearCache() {
        // Trigger haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Mock clear
        withAnimation {
            cacheSize = "0.0 MB"
        }
    }
}

@available(iOS 14.0, *)
struct LegalDetailView: View {
    let title: String
    let fileName: String
    @State private var content: String = "Loading..."
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.system(size: 14, design: .serif))
                    .lineSpacing(4)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: loadContent)
        }
    }

    private func loadContent() {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "txt") {
            if let text = try? String(contentsOf: url) {
                self.content = text
            }
        }
    }
}

@available(iOS 15.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
