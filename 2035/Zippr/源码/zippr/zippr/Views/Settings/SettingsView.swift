import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @AppStorage("hasAgreedPrivacy") private var hasAgreedPrivacy: Bool = true
    @AppStorage("enableNotifications") private var enableNotifications: Bool = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour: Int = 8
    @AppStorage("backgroundPlayEnabled") private var backgroundPlayEnabled: Bool = true
    @State private var showPrivacyPolicy = false
    @State private var showResetAlert = false
    
    @StateObject private var coinManager = CoinManager.shared

    private let version = "1.0.0"
    private let build   = "1"

    @available(iOS 15.0, *)
    var body: some View {
        NavigationView {
            ZStack {
                Color.zBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Wallet / Coin banner
                        if #available(iOS 15.0, *) {
                            coinWalletBanner
                        }
                        
                        // App header card
                        appHeaderCard

                        // Stats card
                        statsCard

                        // Notifications section
//                        settingsSection("Notifications") {
//                            if #available(iOS 16.0, *) {
//                                SettingsToggleRow(
//                                    icon: "bell.badge",
//                                    iconColor: Color.zPrimary,
//                                    title: "Daily Reminder",
//                                    subtitle: "Get reminded to work out every day",
//                                    isOn: $enableNotifications
//                                )
//                            }
//                        }
                        
                        // Video Playback section
                        settingsSection("Video Playback") {
                            if #available(iOS 16.0, *) {
                                SettingsToggleRow(
                                    icon: "play.tv",
                                    iconColor: Color.zAccent,
                                    title: "Background Playback",
                                    subtitle: "Keep audio playing when app is minimized",
                                    isOn: $backgroundPlayEnabled
                                )
                            } else {
                                // Fallback on earlier versions
                            }
                        }

                        // About section
                        settingsSection("About") {
                            Button { showPrivacyPolicy = true } label: {
                                SettingsNavRow(icon: "shield.checkered",
                                              iconColor: Color.zPrimary,
                                              title: "Privacy Policy",
                                              subtitle: "Read our privacy commitments")
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider().padding(.leading, 52)

                            SettingsInfoRow(icon: "info.circle",
                                          iconColor: Color.zSecondary,
                                          title: "Version",
                                          value: "\(version) (\(build))")

                            Divider().padding(.leading, 52)

                            SettingsInfoRow(icon: "iphone",
                                          iconColor: Color.zAccent,
                                          title: "Platform",
                                          value: "iOS \(UIDevice.current.systemVersion)")
                        }

                        // Reset section
                        settingsSection("Data") {
                            Button {
                                showResetAlert = true
                            } label: {
                                SettingsNavRow(icon: "trash",
                                              iconColor: .red,
                                              title: "Reset All Data",
                                              subtitle: "Clear favorites, programs & history")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicySheetView()
            }
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will clear all your favorites, enrolled programs, and workout history. This action cannot be undone.")
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Coin Wallet Banner
    @available(iOS 15.0, *)
    private var coinWalletBanner: some View {
        NavigationLink(destination: CoinShopView()) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Coins")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.zTextSub)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(Color(hex: "#FFC107"))
                            .font(.system(size: 20))
                        
                        Text("\(coinManager.balance)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.zText)
                    }
                }
                
                Spacer()
                
                Text("Top Up")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.zPrimary)
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.zPrimary.opacity(0.1), lineWidth: 1)
            )
        }
    }

    // MARK: - App Header
    private var appHeaderCard: some View {
        VStack(spacing: 10) {
            ZStack {
                LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                    .shadow(color: Color.zPrimary.opacity(0.4), radius: 12, x: 0, y: 6)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
            }
            Text("Zippr")
                .font(.zTitle(24))
                .foregroundColor(Color.zText)
            Text("Body Sculpting & Fitness")
                .font(.zBody(13))
                .foregroundColor(Color.zTextSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.zPrimary.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 0) {
            miniStat(icon: "heart.fill",
                     value: "\(FavoritesManager.shared.favoriteIDs.count)",
                     label: "Favorites")
            Divider().frame(height: 40)
            miniStat(icon: "bolt.fill",
                     value: "\(WorkoutTimerManager.shared.workoutStreak)",
                     label: "Day Streak")
            Divider().frame(height: 40)
            miniStat(icon: "clock.fill",
                     value: WorkoutTimerManager.shared.formattedTotal,
                     label: "Trained")
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(colors: [Color.zPrimary.opacity(0.07), Color.zAccent.opacity(0.04)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.zPrimary.opacity(0.1), lineWidth: 1))
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Color.zPrimary)
                .font(.system(size: 14))
            Text(value)
                .font(.zHeadline(16))
                .foregroundColor(Color.zText)
            Text(label)
                .font(.zCaption(10))
                .foregroundColor(Color.zTextSub)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Section builder
    @ViewBuilder
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.zTextSub)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.zPrimary.opacity(0.05), radius: 8, x: 0, y: 3)
        }
    }

    // MARK: - Reset
    private func resetAllData() {
        FavoritesManager.shared.favoriteIDs = []
        UserDefaults.standard.removeObject(forKey: "favoriteItemIDs")
        UserDefaults.standard.removeObject(forKey: "enrolledPrograms")
        UserDefaults.standard.removeObject(forKey: "completedDays")
        UserDefaults.standard.removeObject(forKey: "totalSecondsCompleted")
        UserDefaults.standard.removeObject(forKey: "workoutStreak")
        UserDefaults.standard.removeObject(forKey: "lastWorkoutDate")
    }
}

// MARK: - Reusable Row Components

@available(iOS 16.0, *)
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            iconBox(icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.zBody(15))
                    .foregroundColor(Color.zText)
                Text(subtitle)
                    .font(.zCaption(12))
                    .foregroundColor(Color.zTextSub)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(Color.zPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

struct SettingsNavRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            iconBox(icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.zBody(15))
                    .foregroundColor(Color.zText)
                Text(subtitle)
                    .font(.zCaption(12))
                    .foregroundColor(Color.zTextSub)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.zTextSub.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            iconBox(icon, color: iconColor)
            Text(title)
                .font(.zBody(15))
                .foregroundColor(Color.zText)
            Spacer()
            Text(value)
                .font(.zBody(14))
                .foregroundColor(Color.zTextSub)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private func iconBox(_ icon: String, color: Color) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.opacity(0.12))
            .frame(width: 34, height: 34)
        Image(systemName: icon)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(color)
    }
}

// MARK: - Privacy Policy Sheet (for Settings re-read)
@available(iOS 14.0, *)
struct PrivacyPolicySheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var policyText = ""

    var body: some View {
        NavigationView {
            ScrollView {
                Text(policyText.isEmpty ? "Loading…" : policyText)
                    .font(.system(size: 14))
                    .foregroundColor(Color.zText.opacity(0.85))
                    .lineSpacing(5)
                    .padding(20)
            }
            .background(Color.zBackground.ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(Color.zPrimary))
        }
        .onAppear {
            guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "txt"),
                  let text = try? String(contentsOf: url, encoding: .utf8) else {
                policyText = "Privacy policy not available."
                return
            }
            policyText = text
        }
    }
}
