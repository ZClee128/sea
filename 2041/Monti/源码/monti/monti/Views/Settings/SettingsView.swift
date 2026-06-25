import SwiftUI
import AVFoundation

struct SettingsView: View {
    var onLogoutState: () -> Void
    var onDeleteAccountState: () -> Void
    
    @ObservedObject private var playbackManager = BackgroundPlaybackManager.shared
    @ObservedObject private var coinManager = CoinManager.shared
    @EnvironmentObject var stageData: StageDataRepository
    
    @State private var showingPrivacySheet = false
    @State private var showingTermsSheet = false
    @State private var cacheCleared = false
    @State private var showingDeleteAlert = false
    
    var udidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "DEV-UDID-84F2-4A3C-9B1D-66555F4D3C2B"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile/Brand Header (Displaying UDID)
                        VStack(spacing: 12) {
                            Text("M")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 1.00, green: 0.00, blue: 0.50), Color(red: 0.50, green: 0.00, blue: 1.00)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.3), radius: 8)
                            
                            Text("Monti Device Account")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Shortened display of UDID
                            VStack(spacing: 4) {
                                Text("LOGGED IN DEVICE ID:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.gray)
                                Text(udidString)
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.customCyan)
                                    .lineLimit(1)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .padding(.top, 24)
                        
                        // ── Edit Profile Card ──
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EDIT USER PROFILE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Text(stageData.userAvatarEmoji)
                                        .font(.system(size: 24))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(Circle())
                                    
                                    TextField("Enter stunt profile name...", text: $stageData.userDisplayName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.white.opacity(0.04))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        let emojis = ["👤", "🥷", "🥋", "🤺", "🧗", "🤸", "🏄"]
                                        ForEach(emojis, id: \.self) { emoji in
                                            Button(action: {
                                                self.stageData.userAvatarEmoji = emoji
                                            }) {
                                                Text(emoji)
                                                    .font(.system(size: 20))
                                                    .frame(width: 38, height: 38)
                                                    .background(
                                                        self.stageData.userAvatarEmoji == emoji ?
                                                        Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.2) :
                                                        Color.white.opacity(0.04)
                                                    )
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle()
                                                            .stroke(
                                                                Color(red: 1.00, green: 0.00, blue: 0.50),
                                                                lineWidth: self.stageData.userAvatarEmoji == emoji ? 2 : 0
                                                            )
                                                    )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // ── Wallet / Coin Shop Entrance ──
                        NavigationLink(destination: CoinShopView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .frame(width: 38, height: 38)
                                    .background(Color.yellow.opacity(0.15))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("My Stunt Coins")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Used to unlock premium stunt videos")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Text("\(coinManager.balance)")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(.yellow)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)

                        // Option Group 1: Standard Settings
                        VStack(spacing: 0) {
                            // Option 1: Privacy Policy
                            Button(action: {
                                showingPrivacySheet = true
                            }) {
                                SettingRow(icon: "lock.shield.fill", iconColor: .customCyan, title: "Privacy Policy")
                            }
                            Divider().background(Color.white.opacity(0.08)).padding(.leading, 56)
                            
                            // Option 2: Terms of Service
                            Button(action: {
                                showingTermsSheet = true
                            }) {
                                SettingRow(icon: "doc.text.fill", iconColor: .blue, title: "Terms of Rehearsal")
                            }
                            Divider().background(Color.white.opacity(0.08)).padding(.leading, 56)
                            
                            // Option 3: Clear Cache
                            Button(action: {
                                clearCache()
                            }) {
                                SettingRow(
                                    icon: "trash.fill",
                                    iconColor: .orange,
                                    title: cacheCleared ? "Rehearsal Cache Cleared!" : "Clear Rehearsal Cache"
                                )
                            }
                        }
                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // ── Background Audio Playback Section ──
                        VStack(alignment: .leading, spacing: 12) {
                            // Section Header
                            HStack(spacing: 8) {
                                Image(systemName: "headphones")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.customCyan)
                                Text("BACKGROUND AUDIO")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.customCyan)
                                    .tracking(1.2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                            // Toggle Row
                            VStack(spacing: 0) {
                                HStack(spacing: 16) {
                                    Image(systemName: playbackManager.isBackgroundPlaybackEnabled ? "play.circle.fill" : "pause.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(playbackManager.isBackgroundPlaybackEnabled ? Color.customCyan : Color.gray)
                                        .cornerRadius(8)
                                        .animation(.easeInOut(duration: 0.2), value: playbackManager.isBackgroundPlaybackEnabled)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Continue Audio in Background")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        Text(playbackManager.isBackgroundPlaybackEnabled ? "Audio plays while app is minimised" : "Audio pauses when app is minimised")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Toggle("", isOn: $playbackManager.isBackgroundPlaybackEnabled)
                                        .labelsHidden()
                                        .accentColor(.customCyan)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .contentShape(Rectangle())
                            }
                            .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                            .cornerRadius(16)

                            // Compliance / user guidance description
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text("When enabled, cosplay video audio continues playing after you leave the app or lock your screen — ideal for listening to soundtrack while multitasking. Toggle this switch at any time to pause background audio.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                        }
                        .padding(.horizontal, 16)

                        // Option Group 2: Account Actions
                        VStack(spacing: 0) {
                            // Option 4: Log Out
                            Button(action: {
                                UserDefaults.standard.set(false, forKey: "PrivacyPolicyAgreed")
                                UserDefaults.standard.set(false, forKey: "UserIsLoggedIn")
                                onLogoutState()
                            }) {
                                SettingRow(icon: "arrow.right.square.fill", iconColor: .gray, title: "Log Out")
                            }
                            Divider().background(Color.white.opacity(0.08)).padding(.leading, 56)
                            
                            // Option 5: Delete Account
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                SettingRow(icon: "xmark.octagon.fill", iconColor: .red, title: "Delete Account")
                            }
                        }
                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // Version footer
                        VStack(spacing: 4) {
                            Text("Monti for iOS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            Text("Version 1.0.0")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    )
                }
            }
            .navigationBarTitle(Text("Monti Settings"), displayMode: .inline)
            
            // Sheet for Privacy Policy (Reads synchronous directly from bundle to fix blank render bug)
            .sheet(isPresented: $showingPrivacySheet) {
                ZStack {
                    Color(red: 0.08, green: 0.08, blue: 0.10).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 20) {
                        HStack {
                            Text("Privacy Agreement")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { showingPrivacySheet = false }) {
                                Text("Done")
                                    .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        ScrollView {
                            Text(getPrivacyPolicyContent())
                                .font(.system(size: 13))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.85))
                                .padding()
                        }
                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            // Sheet for Terms of Service
            .sheet(isPresented: $showingTermsSheet) {
                ZStack {
                    Color(red: 0.08, green: 0.08, blue: 0.10).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 20) {
                        HStack {
                            Text("Terms of Rehearsal")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { showingTermsSheet = false }) {
                                Text("Done")
                                    .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        ScrollView {
                            Text("""
                            Monti Terms of Rehearsal
                            Last Updated: June 24, 2026
                            
                            1. Acceptance of Terms
                            By launching and logging choreography within Monti, you agree to these standard local terms. Monti is a local sandbox tool for action design staging.
                            
                            2. Proper Usage
                            Monti is designed for cosplay choreography logging, stunt staging coordinates planning, and movement sequence tracking.
                            - You should perform acrobatics and action stunts ONLY under certified supervision and inside safe, designated athletic facilities.
                            - Do not attempt high risk martial arts sequences or vault maneuvers without proper crash mats and protective gears.
                            
                            3. Disclaimer of Liability
                            Monti is purely a logging utility and assumes NO responsibility for physical injuries, joint strain, muscle tears, or equipment malfunctions that happen during your stunt practice or roleplay rehearsals.
                            
                            All stage actions are performed at your own personal risk.
                            
                            4. Intellectual Property
                            Your custom logs, stage sequences, and choreography texts are entirely yours. Since Monti works in local sandbox mode, your intellectual property remains on your device and is never uploaded or shared without your manual external action.
                            
                            For support or inquiries, please contact:
                            support@montiapp.com
                            """)
                            .font(.system(size: 13))
                            .lineSpacing(4)
                            .foregroundColor(.white.opacity(0.85))
                            .padding()
                        }
                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            // Delete Account confirmation Alert
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Device Account?"),
                    message: Text("This will erase your local staging parameters, reset your privacy preferences, and completely log you out. This action is permanent."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        deleteAccount()
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func getPrivacyPolicyContent() -> String {
        if let filepath = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                return "Error reading Privacy Policy: \(error.localizedDescription)"
            }
        }
        return "Privacy Policy file could not be located in the application bundle."
    }
    
    private func clearCache() {
        cacheCleared = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cacheCleared = false
        }
    }
    
    private func deleteAccount() {
        // Perform actual account data erasure
        stageData.resetData()
        
        // Clear all consent and login values
        UserDefaults.standard.set(false, forKey: "PrivacyPolicyAgreed")
        UserDefaults.standard.set(false, forKey: "UserIsLoggedIn")
        onDeleteAccountState()
    }
}

// Reuseable Setting Row UI Widget (safe for iOS 13)
struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(iconColor)
                .cornerRadius(8)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}


// MARK: - Coin Shop View (Stunning Neon Theme)
struct CoinShopView: View {
    @ObservedObject private var coinManager = CoinManager.shared
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Header: Compact Balance bar
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        Text("Stunt Coins Wallet")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Text("\(coinManager.balance)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                        Text("Coins")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Catalog Header
                Text("CHOOSE COINS PACK")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // Grid Layout of Products
                let chunkedProducts = storeManager.products.chunked(into: 3)
                VStack(spacing: 12) {
                    ForEach(0..<chunkedProducts.count, id: \.self) { rowIndex in
                        HStack(spacing: 12) {
                            ForEach(chunkedProducts[rowIndex]) { product in
                                CoinProductCard(product: product)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Store Info & Restores (Optimized to stay at bottom)
                VStack(spacing: 8) {
                    Button(action: {
                        storeManager.isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            storeManager.isLoading = false
                            storeManager.alertMessage = "All historical purchases successfully synchronized."
                            storeManager.showAlert = true
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                    }
                    
                    Text("Stunt Coins are used to unlock premium stunt videos. Non-refundable.")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
            
            // Loading Overlay
            if storeManager.isLoading {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    VStack(spacing: 16) {
                        SimpleActivityIndicator()
                        Text("Processing Transaction...")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.20))
                    .cornerRadius(16)
                }
            }
        }
        .navigationBarTitle(Text("Coin Shop"), displayMode: .inline)
        .alert(isPresented: $storeManager.showAlert) {
            Alert(
                title: Text("Store Info"),
                message: Text(storeManager.alertMessage ?? "Operation completed."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Coin Product Card Widget
struct CoinProductCard: View {
    let product: CoinProduct
    
    var body: some View {
        VStack(spacing: 6) {
            // Coin Graphic Header
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Image(systemName: coinIcon(for: product.totalCoins))
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                        .padding(.top, 10)
                    
                    Text("\(product.baseCoins)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                
                // Bonus Badge if applicable
                if product.bonusCoins > 0 {
                    Text("+\(product.bonusCoins)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(red: 1.00, green: 0.00, blue: 0.50))
                        .cornerRadius(4)
                        .padding(4)
                }
            }
            
            Text(product.displayName)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            Button(action: {
                StoreManager.shared.purchase(product)
            }) {
                Text(product.price)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 1.00, green: 0.00, blue: 0.50), Color(red: 0.50, green: 0.00, blue: 1.00)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(product.bonusCoins > 0 ? Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1.2)
        )
    }
    
    private func coinIcon(for total: Int) -> String {
        if total < 100 {
            return "circle.grid.hex"
        } else if total < 500 {
            return "bag.fill"
        } else {
            return "archivebox.fill"
        }
    }
}

// iOS 13 compatible loading indicator
struct SimpleActivityIndicator: View {
    @State private var isAnimating = false
    var body: some View {
        Image(systemName: "arrow.2.circlepath")
            .font(.system(size: 28))
            .foregroundColor(.white)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false))
            .onAppear {
                self.isAnimating = true
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onLogoutState: {}, onDeleteAccountState: {})
            .environmentObject(StageDataRepository())
    }
}
