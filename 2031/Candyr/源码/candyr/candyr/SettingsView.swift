import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @State private var showingTerms = false
    
    @AppStorage("backgroundLoopEnabled") private var backgroundLoopEnabled = true
    @State private var showingStore = false
    @ObservedObject var coinManager = CoinManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("WALLET").foregroundColor(.gray)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Balance")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack(spacing: 8) {
                                Image(systemName: "circle.hexagongrid.fill")
                                    .foregroundColor(NeonCouture.primary)
                                Text("\(coinManager.balance)")
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .neonGlow()
                            }
                        }
                        Spacer()
                        Button(action: { showingStore = true }) {
                            Text("GIFT COINS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(NeonCouture.primary)
                                .cornerRadius(25)
                                .neonGlow()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .fullScreenCover(isPresented: $showingStore) {
                            if #available(iOS 15.0, *) {
                                CoinStoreView()
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("PREFERENCES").foregroundColor(.gray)) {
                    Toggle(isOn: $backgroundLoopEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Background Loop Playback")
                            Text("Allow video audio to continue when App is in background.")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("COLLECTIONS").foregroundColor(.gray)) {
                    NavigationLink(destination: InspirationsView()) {
                        HStack {
                            Text("My Mood Board")
                            Spacer()
                            Image(systemName: "heart.fill")
                                .foregroundColor(NeonCouture.primary)
                        }
                    }
                }
                
                Section(header: Text("APP INFO").foregroundColor(.gray)) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Candyr").foregroundColor(.gray)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("LEGAL").foregroundColor(.gray)) {
                    Button(action: {
                        showingPrivacyOnly = false
                        showingTerms = true
                    }) {
                        HStack {
                            Text("Terms of Service")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        // We will use the same sheet logic but load Privacy
                        loadAndShowPrivacy()
                    }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("SUPPORT").foregroundColor(.gray)) {
                    HStack {
                        Text("Contact Us")
                        Spacer()
                        Text("tranthilieu8192@icloud.com").foregroundColor(NeonCouture.primary)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
            .sheet(isPresented: $showingTerms) {
                TermsSheetView(isPrivacy: showingPrivacyOnly)
            }
        }
    }
    
    @State private var showingPrivacyOnly = false
    func loadAndShowPrivacy() {
        showingPrivacyOnly = true
        showingTerms = true
    }
}

struct TermsSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    var isPrivacy: Bool
    @State private var contentText: String = "Loading..."
    
    var body: some View {
        VStack {
            HStack {
                Text(isPrivacy ? "Privacy Policy" : "Terms of Service")
                    .font(.headline)
                    .padding(.leading,10)
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            
            ScrollView {
                Text(contentText)
                    .padding()
            }
        }
        .onAppear {
            let fileName = isPrivacy ? "PrivacyPolicy" : "TermsOfService"
            if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
                self.contentText = (try? String(contentsOfFile: path)) ?? "Content not found."
            }
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
