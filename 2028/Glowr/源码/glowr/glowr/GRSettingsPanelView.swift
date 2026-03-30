import SwiftUI
import MediaPlayer
import StoreKit

@available(iOS 14.0, *)
struct GRSettingsPanelView: View {
    @State private var notificationsEnabled = true
    @State private var hapticFeedback = true
    @AppStorage("backgroundAudioEnabled") private var backgroundAudioEnabled = true
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showStore = false
    @ObservedObject var store = GRStoreRegistry.shared
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                header
                
                List {
                    Section(header: Text("ACCOUNT").foregroundColor(.gray)) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.gold)
                            Text("Vault Credits")
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(GRStoreRegistry.shared.coins)")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        
                        Button(action: { showStore = true }) {
                            HStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.black)
                                Text("Recharge Credits")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section(header: Text("PLAYBACK").foregroundColor(.gray)) {
                        Toggle(isOn: $backgroundAudioEnabled) { 
                            HStack {
                                Image(systemName: "waveform.circle.fill")
                                    .foregroundColor(.black)
                                Text("Background Audio")
                                    .foregroundColor(.black)
                            }
                        }
                        .onChange(of: backgroundAudioEnabled) { newValue in
                            // Optional: immediately stop anything playing if turned off
                            if !newValue {
                                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
                            }
                        }
                        if #available(iOS 14.0, *) {
                            Text("Allows Reels audio to continue playing when the app is in the background.")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    Section(header: Text("SUPPORT").foregroundColor(.gray)) {
                        Button("Privacy Policy") {
                            showPrivacy = true
                        }
                        .foregroundColor(.black)
                        Button("Terms of Service") {
                            showTerms = true
                        }
                        .foregroundColor(.black)
                    }
                    
                    Section(header: Text("APP INFO").foregroundColor(.gray)) {
                        HStack {
                            Text("Version")
                                .foregroundColor(.black)
                            Spacer()
                            Text("1.1.0")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            UserDefaults.standard.set(false, forKey: "hasAgreedToAIDisclosure")
                        }) {
                            Text("Reset AI Permissions (Developer)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .sheet(isPresented: $showStore) {
            GRCreditStoreView()
        }
        .sheet(isPresented: $showPrivacy) {
            GRLegalDocumentView(fileName: "PrivacyPolicy", title: "PRIVACY POLICY")
        }
        .sheet(isPresented: $showTerms) {
            GRLegalDocumentView(fileName: "TermsOfService", title: "TERMS OF SERVICE")
        }
    }
    
    var header: some View {
        VStack(alignment: .leading) {
            Text("SETTINGS")
                .font(.system(size: 38, weight: .black, design: .serif))
                .tracking(5)
                .foregroundColor(.black)
            Text("PREFERENCES")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct GRSettingsPanelView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            GRSettingsPanelView()
        } else {
            // Fallback on earlier versions
        }
    }
}
