//
//  ProfileView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI
import Combine

// MARK: - Auth State Manager
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn = false
    @Published var email = ""
    @Published var nickname = "Guest User"
    @Published var bio = "Avid mini-drama enthusiast tracking satisfying revenge schemes and sweet romances."
    @Published var selectedAvatarIndex = 0
    
    private let loggedInKey = "melonshare_is_logged_in"
    private let emailKey = "melonshare_user_email"
    private let nicknameKey = "melonshare_user_nickname"
    private let bioKey = "melonshare_user_bio"
    private let avatarKey = "melonshare_user_avatar"
    
    private init() {
        // Pre-populate Apple Reviewer account credentials only upon the first installation
        let firstLaunchKey = "melonshare_first_launch_populated"
        if !UserDefaults.standard.bool(forKey: firstLaunchKey) {
            let reviewEmail = "apple@melon.com"
            let reviewPassword = "apple123"
            UserDefaults.standard.set(reviewPassword, forKey: "melonshare_password_\(reviewEmail)")
            UserDefaults.standard.set("AppleReviewer", forKey: "melonshare_nickname_\(reviewEmail)")
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
            UserDefaults.standard.synchronize()
        }
        
        isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        email = UserDefaults.standard.string(forKey: emailKey) ?? ""
        nickname = UserDefaults.standard.string(forKey: nicknameKey) ?? "DramaKing"
        bio = UserDefaults.standard.string(forKey: bioKey) ?? "Loving sweet CEO romances and satisfying revenge series."
        selectedAvatarIndex = UserDefaults.standard.integer(forKey: avatarKey)
    }
    
    func login(email: String, password: String) -> Bool {
        let lowercasedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordKey = "melonshare_password_\(lowercasedEmail)"
        
        // Support default dev account for testing and general convenience
        if lowercasedEmail == "melon@melon.com" {
            if password == "melon123" || password == "123" {
                self.email = lowercasedEmail
                self.nickname = "MelonDeveloper"
                self.isLoggedIn = true
                UserDefaults.standard.set(true, forKey: loggedInKey)
                UserDefaults.standard.set(lowercasedEmail, forKey: emailKey)
                UserDefaults.standard.set("MelonDeveloper", forKey: nicknameKey)
                UserDefaults.standard.synchronize()
                return true
            }
            return false
        }
        
        // Check local storage database accounts (handles pre-populated apple@melon.com reviewer account)
        if let savedPassword = UserDefaults.standard.string(forKey: passwordKey) {
            if password == savedPassword {
                self.email = lowercasedEmail
                self.isLoggedIn = true
                UserDefaults.standard.set(true, forKey: loggedInKey)
                UserDefaults.standard.set(lowercasedEmail, forKey: emailKey)
                
                if let savedNickname = UserDefaults.standard.string(forKey: "melonshare_nickname_\(lowercasedEmail)") {
                    self.nickname = savedNickname
                    UserDefaults.standard.set(savedNickname, forKey: nicknameKey)
                }
                
                UserDefaults.standard.synchronize()
                return true
            }
            return false
        }
        
        return false
    }
    
    func signup(email: String, name: String, password: String) {
        let lowercasedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordKey = "melonshare_password_\(lowercasedEmail)"
        let nicknameKeyForEmail = "melonshare_nickname_\(lowercasedEmail)"
        
        self.email = lowercasedEmail
        self.nickname = name
        self.isLoggedIn = true
        
        UserDefaults.standard.set(true, forKey: loggedInKey)
        UserDefaults.standard.set(lowercasedEmail, forKey: emailKey)
        UserDefaults.standard.set(name, forKey: nicknameKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
        UserDefaults.standard.set(name, forKey: nicknameKeyForEmail)
        UserDefaults.standard.synchronize()
    }
    
    func updateProfile(name: String, bio: String, avatarIdx: Int) {
        self.nickname = name
        self.bio = bio
        self.selectedAvatarIndex = avatarIdx
        UserDefaults.standard.set(name, forKey: nicknameKey)
        UserDefaults.standard.set(bio, forKey: bioKey)
        UserDefaults.standard.set(avatarIdx, forKey: avatarKey)
        UserDefaults.standard.synchronize()
        objectWillChange.send()
    }
    
    func logout() {
        self.isLoggedIn = false
        UserDefaults.standard.set(false, forKey: loggedInKey)
        UserDefaults.standard.synchronize()
        VideoManager.shared.pause()
    }
    
    func deleteAccount() {
        let userEmail = self.email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        logout()
        
        self.email = ""
        self.nickname = "Guest User"
        self.bio = "Avid mini-drama enthusiast tracking satisfying revenge schemes and sweet romances."
        self.selectedAvatarIndex = 0
        
        UserDefaults.standard.removeObject(forKey: loggedInKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: nicknameKey)
        UserDefaults.standard.removeObject(forKey: bioKey)
        UserDefaults.standard.removeObject(forKey: avatarKey)
        
        // Wipe specific account credentials permanently from database
        if !userEmail.isEmpty {
            let passwordKey = "melonshare_password_\(userEmail)"
            let nicknameKeyForEmail = "melonshare_nickname_\(userEmail)"
            UserDefaults.standard.removeObject(forKey: passwordKey)
            UserDefaults.standard.removeObject(forKey: nicknameKeyForEmail)
        }
        
        UserDefaults.standard.synchronize()
        
        // Reset coins and unlocked content records
        IAPManager.shared.reset()
        
        // Also wipe trackers completely
        WatchlistManager.shared.clearAllData()
    }
}

// MARK: - Profile Screen
struct ProfileView: View {
    @ObservedObject private var auth = AuthManager.shared
    @ObservedObject private var watchManager = WatchlistManager.shared
    @ObservedObject private var iapManager = IAPManager.shared
    
    // Edit profile sheet state
    @State private var showingEditSheet = false
    // Settings actions sheets
    @State private var showingDeleteAlert = false
    @State private var showingLogoutAlert = false
    @State private var showingClearCacheAlert = false
    @State private var showingPrivacySheet = false
    @State private var showingCoinStore = false
    
    // Avatar archetypes
    let avatars = [
        "crown.fill", // Queen
        "briefcase.fill", // CEO
        "hourglass", // Traveler
        "bolt.fill" // Commander
    ]
    let avatarColors = [Color.red, Color.blue, Color.orange, Color.purple]
    let avatarLabels = ["Queen", "CEO", "Chronos", "Commander"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                if auth.isLoggedIn {
                    // MARK: - LOGGED IN PROFILE VIEW
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            
                            // Header
                            ViewHeader(
                                title: "Profile",
                                subtitle: "My Hub"
                            )
                            
                            // User Info Card
                            GlassCard(padding: 20) {
                                HStack(spacing: 16) {
                                    // Avatar Badge representation
                                    Circle()
                                        .fill(avatarColors[auth.selectedAvatarIndex].opacity(0.1))
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Image(systemName: avatars[auth.selectedAvatarIndex])
                                                .font(.title)
                                                .foregroundColor(avatarColors[auth.selectedAvatarIndex])
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(avatarColors[auth.selectedAvatarIndex].opacity(0.3), lineWidth: 2)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(auth.nickname)
                                            .font(.headline)
                                            .bold()
                                            .foregroundColor(Theme.textDark)
                                        
                                        Text(avatarLabels[auth.selectedAvatarIndex] + " Fanatic")
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(.white)
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 8)
                                            .background(avatarColors[auth.selectedAvatarIndex])
                                            .cornerRadius(6)
                                        
                                        Text(auth.bio)
                                            .font(.caption)
                                            .foregroundColor(Theme.textMedium)
                                            .lineLimit(3)
                                            .lineSpacing(2)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Tracking Metrics
                            HStack(spacing: 12) {
                                MiniMetricCard(title: "Tracked", value: "\(watchManager.items.count)", icon: "tv", color: .blue)
                                MiniMetricCard(title: "Completed", value: "\(watchManager.items.filter { $0.status == "Completed" }.count)", icon: "checkmark.seal", color: .green)
                            }
                            .padding(.horizontal, 20)
                            
                            // Melon Coins Card & IAP Store Entry
                            GlassCard(padding: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "bitcoinsign.circle.fill")
                                                .foregroundColor(.orange)
                                                .font(.subheadline)
                                            Text("Melon Coins Balance")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(Theme.textMedium)
                                        }
                                        
                                        Text("\(iapManager.melonCoins)")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundColor(Theme.primaryPeach)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingCoinStore = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "cart.fill")
                                            Text("Get Coins")
                                                .bold()
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 14)
                                        .background(Theme.accentGradient)
                                        .cornerRadius(16)
                                        .shadow(color: Theme.accentPink.opacity(0.3), radius: 6, x: 0, y: 3)
                                    }
                                    .sheet(isPresented: $showingCoinStore) {
                                        CoinStoreSheet(isPresented: $showingCoinStore)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Settings List
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Account Configurations")
                                    .font(.headline)
                                    .foregroundColor(Theme.textDark)
                                    .padding(.horizontal, 20)
                                
                                GlassCard(padding: 8) {
                                    VStack(spacing: 0) {
                                        SettingsRow(icon: "pencil", text: "Edit Profile Info") {
                                            showingEditSheet = true
                                        }
                                        .sheet(isPresented: $showingEditSheet) {
                                            EditProfileSheet(isPresented: $showingEditSheet)
                                        }
                                        
                                        Divider().padding(.leading, 40)
                                        SettingsRow(icon: "doc.text.fill", text: "Privacy Policy") {
                                            showingPrivacySheet = true
                                        }
                                        .sheet(isPresented: $showingPrivacySheet) {
                                            LegalDocumentSheet(title: "Privacy Policy", resourceName: "PrivacyPolicy")
                                        }
                                        
                                        Divider().padding(.leading, 40)
                                        SettingsRow(icon: "trash.fill", text: "Clear Local Caches") {
                                            showingClearCacheAlert = true
                                        }
                                        .alert(isPresented: $showingClearCacheAlert) {
                                            Alert(
                                                title: Text("Clear Local Caches?"),
                                                message: Text("This will clear temporary tracking caches to release storage. Your active watchlists will remain fully secure."),
                                                primaryButton: .default(Text("Wipe Cache")) {
                                                    print("Cache swept successfully")
                                                },
                                                secondaryButton: .cancel()
                                            )
                                        }
                                        Divider().padding(.leading, 40)
                                        SettingsRow(icon: "rectangle.portrait.and.arrow.right", text: "Sign Out") {
                                            showingLogoutAlert = true
                                        }
                                        .alert(isPresented: $showingLogoutAlert) {
                                            Alert(
                                                title: Text("Log Out?"),
                                                message: Text("Are you sure you want to log out of MelonShare?"),
                                                primaryButton: .default(Text("Logout")) {
                                                    auth.logout()
                                                },
                                                secondaryButton: .cancel()
                                            )
                                        }
                                        Divider().padding(.leading, 40)
                                        SettingsRow(icon: "person.crop.circle.badge.xmark", text: "Delete Account Permanently", isDestructive: true) {
                                            showingDeleteAlert = true
                                        }
                                        .alert(isPresented: $showingDeleteAlert) {
                                            Alert(
                                                title: Text("Wipe Account & Data?"),
                                                message: Text("WARNING: Deleting your account will immediately wipe your profile registration, custom review commentaries, and local watchlists permanently. This action cannot be undone."),
                                                primaryButton: .destructive(Text("Delete Permanently")) {
                                                    auth.deleteAccount()
                                                },
                                                secondaryButton: .cancel()
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        }
                    }
                    .background(Theme.backgroundGray)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
    }
    
    
}

// MARK: - Settings Subcomponents
struct SettingsRow: View {
    let icon: String
    let text: String
    var isDestructive = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(isDestructive ? .red : Theme.primaryPeach)
                    .frame(width: 26)
                
                Text(text)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(isDestructive ? .red : Theme.textDark)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(Theme.textLight)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MiniMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption2)
                        .bold()
                        .foregroundColor(Theme.textMedium)
                    Text(value)
                        .font(.headline)
                        .bold()
                        .foregroundColor(Theme.textDark)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Profile Editing Sheet
struct EditProfileSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject private var auth = AuthManager.shared
    
    @State private var nicknameInput = ""
    @State private var bioInput = ""
    @State private var selectedAvatar = 0
    
    let avatars = ["crown.fill", "briefcase.fill", "hourglass", "bolt.fill"]
    let avatarColors = [Color.red, Color.blue, Color.orange, Color.purple]
    let avatarLabels = ["Queen", "CEO", "Chronos", "Commander"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Roster Profile details")) {
                    TextField("Nickname", text: $nicknameInput)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bio Description")
                            .font(.caption)
                            .foregroundColor(Theme.textLight)
                        TextField("Bio Biography", text: $bioInput)
                    }
                }
                
                Section(header: Text("Choose Avatar Archetype")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<avatars.count, id: \.self) { idx in
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(avatarColors[idx].opacity(selectedAvatar == idx ? 0.2 : 0.05))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: avatars[idx])
                                                .font(.headline)
                                                .foregroundColor(avatarColors[idx])
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(avatarColors[idx], lineWidth: selectedAvatar == idx ? 2 : 0)
                                        )
                                    
                                    Text(avatarLabels[idx])
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(selectedAvatar == idx ? avatarColors[idx] : Theme.textLight)
                                }
                                .padding(.vertical, 6)
                                .onTapGesture {
                                    selectedAvatar = idx
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        auth.updateProfile(name: nicknameInput, bio: bioInput, avatarIdx: selectedAvatar)
                        isPresented = false
                    }) {
                        Text("Save Configurations")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .background(Theme.accentGradient)
                            .cornerRadius(10)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { isPresented = false })
            .onAppear {
                nicknameInput = auth.nickname
                bioInput = auth.bio
                selectedAvatar = auth.selectedAvatarIndex
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - COIN STORE COMPONENT
struct CoinStoreSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var iapManager = IAPManager.shared
    
    @State private var purchasingProduct: IAPProduct? = nil
    @State private var showingPaymentSheet = false
    @State private var touchIDSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Header banner
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 36))
                                .foregroundColor(.orange)
                            Text("Melon Coin Store")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Theme.textDark)
                            Text("Unlock locked exclusive drama reviews and bonus content")
                                .font(.caption)
                                .foregroundColor(Theme.textMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        
                        // Balance Card
                        HStack {
                            Text("Current Balance:")
                                .font(.subheadline)
                                .foregroundColor(Theme.textMedium)
                            Spacer()
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.orange)
                            Text("\(iapManager.melonCoins) Coins")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Theme.primaryPeach)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        
                        // IAP Vertical List (Fully iOS 13 Compatible!)
                        VStack(spacing: 12) {
                            ForEach(iapManager.products) { product in
                                Button(action: {
                                    startPurchase(product)
                                }) {
                                    HStack(spacing: 16) {
                                        // Coins icon
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Image(systemName: "bitcoinsign.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(.orange)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text(product.displayName)
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundColor(Theme.textDark)
                                                
                                                if product.bonus > 0 {
                                                    Text("+\(product.bonus) Bonus")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 2)
                                                        .padding(.horizontal, 6)
                                                        .background(Color.red)
                                                        .cornerRadius(4)
                                                }
                                            }
                                            
                                            Text("Prepaid In-App Package Product")
                                                .font(.caption2)
                                                .foregroundColor(Theme.textMedium)
                                        }
                                        
                                        Spacer()
                                        
                                        // Price Button tag
                                        Text(product.price)
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                            .background(Theme.accentGradient)
                                            .cornerRadius(10)
                                            .shadow(color: Theme.accentPink.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
                
                // MOCK APPLE APP STORE TOUCH ID / FACE ID POP-UP SHEET!
                if showingPaymentSheet, let product = purchasingProduct {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                    
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            // Top indicator bar
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 5)
                                .padding(.top, 8)
                            
                            // App Store info
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Theme.accentGradient)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "sparkles.tv")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("MelonShare App Store Purchase")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(product.displayName)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text("Account: \(AuthManager.shared.email)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            Divider()
                            
                            // Apple Pay details
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Price")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(product.price)
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 24)
                                
                                HStack {
                                    Text("Billing")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("App Store Account Balance")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // Touch ID Scan / StoreKit State Area
                            VStack(spacing: 12) {
                                if iapManager.transactionState == .purchasing {
                                    StoreSpinnerView()
                                        .padding(.vertical, 8)
                                    Text("Securing App Store transaction...")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.gray)
                                } else if iapManager.transactionState == .success {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green)
                                        .scaleEffect(1.1)
                                    Text("Payment Confirmed!")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)
                                } else if iapManager.transactionState == .failed {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.red)
                                    Text("Transaction Cancelled or Failed")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 60))
                                        .foregroundColor(Theme.primaryPeach)
                                    Text("Confirm purchase with Double Click or Face ID")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 16)
                            
                            // Pay/Cancel Buttons
                            if iapManager.transactionState == .idle || iapManager.transactionState == .failed {
                                Button(action: {
                                    iapManager.buyProduct(product)
                                }) {
                                    Text("Pay Now")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black)
                                        .cornerRadius(12)
                                        .padding(.horizontal, 24)
                                }
                                
                                Button(action: {
                                    showingPaymentSheet = false
                                    purchasingProduct = nil
                                    iapManager.transactionState = .idle
                                }) {
                                    Text("Cancel")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 10)
                                }
                            } else if iapManager.transactionState == .purchasing {
                                Text("Processing secure checkout...")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 12)
                            } else {
                                Spacer().frame(height: 20)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(radius: 20)
                        .transition(.move(edge: .bottom))
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .onReceive(iapManager.$transactionState) { state in
                        if state == .success {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    showingPaymentSheet = false
                                    purchasingProduct = nil
                                    isPresented = false // auto-close store upon successful purchase!
                                }
                                iapManager.transactionState = .idle // Reset state
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Store", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
    
    private func startPurchase(_ product: IAPProduct) {
        purchasingProduct = product
        iapManager.transactionState = .idle
        withAnimation {
            showingPaymentSheet = true
        }
    }
}

struct StoreSpinnerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(Theme.primaryPeach, lineWidth: 4)
            .frame(width: 44, height: 44)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                self.isAnimating = true
            }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
