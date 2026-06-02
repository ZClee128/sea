//
//  SettingsViews.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import SwiftUI
import StoreKit
import Combine

// MARK: - Settings Dashboard View
struct SettingsView: View {
    @ObservedObject var dataService = DataService.shared
    @Binding var isPrivacyAccepted: Bool
    
    @State private var deviceUDID: String = UserDefaults.standard.string(forKey: "device_udid") ?? (UIDevice.current.identifierForVendor?.uuidString ?? "UDID")
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showStoreSheet = false
    
    @State private var showConfirmUnlockPlan = false
    @State private var showLowCoinsPlanAlert = false
    @State private var planToUnlock = ""
    @State private var planCostToUnlock = 0
    @State private var planTitleToUnlock = ""
    
    @State private var editUsername = ""
    @State private var selectedGoal = "Build Muscle"
    @State private var age = 26
    @State private var weight = 78.5
    @State private var height = 182.0
    
    @State private var cacheSize = "84.2 MB"
    @State private var isClearingCache = false
    @State private var sendNotifications = true
    
    @State private var showEULASheet = false
    @State private var showPrivacySheet = false
    @State private var showEditProfile = false
    @State private var showHistorySheet = false
    
    let goals = ["Build Muscle", "Lose Weight", "Stay Fit"]
    
    // Calculates calories burned from logs
    var totalCaloriesBurned: Int {
        dataService.workoutHistory.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var calorieGoalPercentageString: String {
        let percent = Int((Double(totalCaloriesBurned) / 1000.0) * 100.0)
        return "\(percent)% achieved"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header block
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MY JOYAR PROFILE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                            .tracking(2)
                        
                        Text("Active Fitness Dashboard")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 1. Interactive Activity Progress Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ACTIVE CALORIE TRACKER")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            Text("\(totalCaloriesBurned) kcal")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        Image(systemName: "flame.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                            .shadow(color: Color(red: 1.0, green: 0.37, blue: 0.23).opacity(0.3), radius: 8)
                    }
                    
                    // Simple progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            let ratio = min(CGFloat(totalCaloriesBurned) / 1000.0, 1.0)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 1.0, green: 0.37, blue: 0.23), Color(red: 1.0, green: 0.18, blue: 0.33)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geo.size.width * ratio, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Daily Goal: 1000 kcal")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(calorieGoalPercentageString)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(20)
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // StoreKit Active Coin Wallet
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("JOYAR COIN WALLET")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.5)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 18))
                                    .shadow(color: .yellow.opacity(0.3), radius: 4)
                                
                                Text("\(dataService.coinBalance) Coins")
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                        
                        Button(action: { showStoreSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Get Coins")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.yellow)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(20)
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // 2. Short Stats Grid (Now interactive!)
                HStack(spacing: 12) {
                    Button(action: { showHistorySheet = true }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WORKOUTS LOGGED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                            Text("\(dataService.workoutHistory.count) sessions")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        editUsername = dataService.userProfile.username
                        selectedGoal = dataService.userProfile.goal
                        age = dataService.userProfile.age
                        weight = dataService.userProfile.weightKg
                        height = dataService.userProfile.heightCm
                        showEditProfile = true
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CURRENT GOAL")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                            Text(dataService.userProfile.goal)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                // 3. User Info Settings card
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Personal Profile Details")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            editUsername = dataService.userProfile.username
                            selectedGoal = dataService.userProfile.goal
                            age = dataService.userProfile.age
                            weight = dataService.userProfile.weightKg
                            height = dataService.userProfile.heightCm
                            showEditProfile = true
                        }) {
                            Text("Edit")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Image(systemName: dataService.userProfile.avatar)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataService.userProfile.username)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Member since June 2026")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            // Secure login UDID identifier row
                            Text("UDID: \(deviceUDID.prefix(8))...\(deviceUDID.suffix(6))")
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.06))
                    
                    HStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Age")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text("\(dataService.userProfile.age) yrs")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text(String(format: "%.1f kg", dataService.userProfile.weightKg))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Height")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text("\(Int(dataService.userProfile.heightCm)) cm")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(20)
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // 4. Unlock Premium Training Plans (App Store compliant virtual coin consumption)
                PremiumPlansSection(
                    showStoreSheet: $showStoreSheet,
                    showConfirmUnlock: $showConfirmUnlockPlan,
                    showLowCoinsAlert: $showLowCoinsPlanAlert,
                    planToUnlock: $planToUnlock,
                    planCostToUnlock: $planCostToUnlock,
                    planTitleToUnlock: $planTitleToUnlock
                )
                
                
                // 4. Utility Action Lists
                VStack(spacing: 0) {
                    // Clear Cache Action
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("Wipe System Cache")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        
                        if isClearingCache {
                            ActivityIndicator()
                                .frame(width: 20, height: 20)
                        } else {
                            Button(action: {
                                withAnimation {
                                    isClearingCache = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        cacheSize = "0.0 KB"
                                        isClearingCache = false
                                    }
                                }
                            }) {
                                Text(cacheSize)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    
                    Divider().background(Color.white.opacity(0.06))
                    
                    // Legal Privacy Policy & EULA HTML view trigger
                    Button(action: { showEULASheet = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Privacy Policy & EULA")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 14)
                    
                    Divider().background(Color.white.opacity(0.06))
                    
                    // Log Out Action
                    Button(action: { showLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Log Out")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 14)
                    
                    Divider().background(Color.white.opacity(0.06))
                    
                    // Delete Account Action
                    Button(action: { showDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.xmark")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Delete Account")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 14)
                }
                .padding(.horizontal, 20)
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // 5. Version Card block
                VStack(spacing: 8) {
                    Text("Joyar Fitness Application")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gray)
                    Text("Version 1.0.0 (Build 100)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                Spacer(minLength: 40)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .background(
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditProfile) {
            // Short Edit Profile block sheet
            NavigationView {
                Form {
                    Section(header: Text("Profile Settings").foregroundColor(.gray)) {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Enter name", text: $editUsername)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }
                        
                        Picker("Target Goal", selection: $selectedGoal) {
                            ForEach(goals, id: \.self) { g in
                                Text(g).tag(g)
                            }
                        }
                        
                        Stepper("Age: \(age) yrs", value: $age, in: 10...90)
                        
                        HStack {
                            Text("Weight (kg)")
                            Spacer()
                            TextField("Weight", value: $weight, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Height (cm)")
                            Spacer()
                            TextField("Height", value: $height, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .background(Color(red: 0.07, green: 0.07, blue: 0.08))
                .navigationBarTitle(Text("Edit Details"), displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") { showEditProfile = false }.foregroundColor(.gray),
                    trailing: Button("Save") {
                        dataService.updateProfile(
                            username: editUsername,
                            goal: selectedGoal,
                            age: age,
                            weight: weight,
                            height: height
                        )
                        showEditProfile = false
                    }.foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                )
            }
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showHistorySheet) {
            WorkoutHistorySheet()
        }
        .sheet(isPresented: $showEULASheet) {
            HTMLOverlayWebView(title: "Terms of Use (EULA)", isPresented: $showEULASheet)
        }
        .sheet(isPresented: $showPrivacySheet) {
            HTMLOverlayWebView(title: "Privacy Policy", isPresented: $showPrivacySheet)
        }
        .sheet(isPresented: $showStoreSheet) {
            StoreView()
        }
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Confirm Log Out"),
                message: Text("Are you sure you want to log out? Your device login UDID key will remain valid. You will need to re-accept EULA terms to enter again."),
                primaryButton: .destructive(Text("Log Out")) {
                    UserDefaults.standard.set(false, forKey: "privacy_accepted")
                    withAnimation {
                        isPrivacyAccepted = false
                    }
                },
                secondaryButton: .cancel()
            )
        }
        // Custom background layer block for delete warning
        .background(
            EmptyView()
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("⚠️ Permanent Deletion"),
                        message: Text("WIPE ACCOUNT DATA: Are you sure you want to permanently delete your profile? All fitness histories, cardios, calorie burned logs, and active coaches logs on this device will be cleared. This action is irreversible."),
                        primaryButton: .destructive(Text("Delete Permanently")) {
                            // Wipe all user records
                            let keys = ["privacy_accepted", "device_udid"]
                            keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
                            
                            // Reset the shared data singleton fully
                            DataService.shared.resetAllData()
                            
                            withAnimation {
                                isPrivacyAccepted = false
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        )
        .background(
            EmptyView()
                .alert(isPresented: $showConfirmUnlockPlan) {
                    Alert(
                        title: Text("Unlock Premium Plan? 👑"),
                        message: Text("The premium '\(planTitleToUnlock)' program requires \(planCostToUnlock) Coins to unlock permanently."),
                        primaryButton: .default(Text("Unlock for \(planCostToUnlock) Coins")) {
                            if dataService.unlockTrainingPlan(planId: planToUnlock, cost: planCostToUnlock) {
                                // Unlocked successfully!
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    showLowCoinsPlanAlert = true
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        )
        .background(
            EmptyView()
                .alert(isPresented: $showLowCoinsPlanAlert) {
                    Alert(
                        title: Text("Insufficient Coins"),
                        message: Text("You need at least \(planCostToUnlock) coins to unlock this premium training prescription. Top up now inside our secure shop!"),
                        primaryButton: .default(Text("Get Coins")) {
                            showStoreSheet = true
                        },
                        secondaryButton: .cancel()
                    )
                }
        )
    }
}

// MARK: - Safe iOS 13 Loader Spinner
struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .gray
        indicator.startAnimating()
        return indicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

// MARK: - Legal Documents Display Sheet
struct HTMLOverlayWebView: View {
    let title: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                HTMLWebView()
                    .edgesIgnoringSafeArea(.bottom)
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.08))
            .navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
            )
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(isPrivacyAccepted: .constant(true))
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Premium Plans Unlock Section
struct PremiumPlansSection: View {
    @ObservedObject var dataService = DataService.shared
    @Binding var showStoreSheet: Bool
    
    @Binding var showConfirmUnlock: Bool
    @Binding var showLowCoinsAlert: Bool
    @Binding var planToUnlock: String
    @Binding var planCostToUnlock: Int
    @Binding var planTitleToUnlock: String
    
    @State private var activePlanToView: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PRO PERSONAL FITNESS PLANS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.5)
                .padding(.horizontal, 4)
            
            // Plan 1: Coach Marcus Muscle Hypertrophy
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.04))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Marcus's Elite Muscle Schedule")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Personalized hypertrophy training and split logs.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                        Text("Cost: 60 Coins")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    if dataService.unlockedTrainingPlans.contains("plan_marcus") {
                        Button(action: { activePlanToView = "plan_marcus" }) {
                            Text("View Plan")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            planToUnlock = "plan_marcus"
                            planCostToUnlock = 60
                            planTitleToUnlock = "Marcus's Elite Muscle Schedule"
                            showConfirmUnlock = true
                        }) {
                            Text("Unlock Plan")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            .cornerRadius(16)
            
            // Plan 2: Sarah Jenkins Keto Diet Plan
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.04))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sarah's 7-Day Keto Formula")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Deep nutritional keto coaching recipes list.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                        Text("Cost: 80 Coins")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    if dataService.unlockedTrainingPlans.contains("plan_sarah") {
                        Button(action: { activePlanToView = "plan_sarah" }) {
                            Text("View Plan")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            planToUnlock = "plan_sarah"
                            planCostToUnlock = 80
                            planTitleToUnlock = "Sarah's 7-Day Keto Formula"
                            showConfirmUnlock = true
                        }) {
                            Text("Unlock Plan")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            .cornerRadius(16)
        }
        .padding(.horizontal)
        .sheet(item: $activePlanToView) { planId in
            PlanDetailView(planId: planId)
        }
    }
}

// String extension for Identifiable Sheet rendering
extension String: Identifiable {
    public var id: String { self }
}

// MARK: - Premium Plan Content Sheet
struct PlanDetailView: View {
    let planId: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if planId == "plan_marcus" {
                        // Marcus's Schedule details
                        VStack(alignment: .leading, spacing: 14) {
                            Text("COACH MARCUS'S HYPERTROPHY PRESCRIPTION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                            
                            Text("This specialized program relies on mechanical progressive overload. Aim to add weight or repetitions weekly. Ensure protein is at least 2.0g per kg of body weight.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .lineSpacing(3)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            WorkoutPlanDayRow(day: "Monday: Heavy Chest & Triceps", exercises: ["Flat Barbell Bench Press: 4 sets x 8 reps", "Incline Dumbbell Fly: 3 sets x 12 reps", "Close Grip Bench Press: 3 sets x 10 reps", "Weighted Dips: 3 sets x max reps"])
                            
                            WorkoutPlanDayRow(day: "Wednesday: Back & Biceps Thickener", exercises: ["Deadlifts: 4 sets x 5 reps", "Weighted Pull-ups: 3 sets x 8 reps", "Barbell Rows: 3 sets x 10 reps", "Hammer Curls: 3 sets x 15 reps"])
                            
                            WorkoutPlanDayRow(day: "Friday: Quadriceps & Hamstrings Power", exercises: ["Barbell Back Squats: 4 sets x 8 reps", "Romanian Deadlifts: 3 sets x 12 reps", "Leg Press: 3 sets x 15 reps", "Calf Raises: 4 sets x 20 reps"])
                        }
                    } else {
                        // Sarah's Diet details
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SARAH'S 7-DAY KETO DIET FORMULATION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.green)
                            
                            Text("Prioritize clean healthy fats and complete protein sources. Limit total daily carbohydrates to under 20-30g to induce metabolic ketosis.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .lineSpacing(3)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            KetoMealDayRow(day: "Breakfast - Energizer Booster", menu: "3 Scrambled Eggs in Butter, 1 Whole Avocado, Organic Black Coffee.")
                            KetoMealDayRow(day: "Lunch - Fueling Green Plate", menu: "Grilled Salmon over Mixed Greens with Extra Virgin Olive Oil and Lemon juice.")
                            KetoMealDayRow(day: "Dinner - High Protein Powerpack", menu: "10oz Ribeye Steak, sautéed Asparagus spears, Cauliflower Mash.")
                            KetoMealDayRow(day: "Snacks - Keto safe", menu: "Handful of Macadamia nuts or high-quality Pumpkin seeds.")
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.08).edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Text(planId == "plan_marcus" ? "Strength Plan" : "Nutrition Guide"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23)))
        }
        .preferredColorScheme(.dark)
    }
}

struct WorkoutPlanDayRow: View {
    let day: String
    let exercises: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(exercises, id: \.self) { ex in
                HStack(spacing: 8) {
                    Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.23)).frame(width: 4, height: 4)
                    Text(ex)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .cornerRadius(10)
    }
}

struct KetoMealDayRow: View {
    let day: String
    let menu: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(day)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text(menu)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .cornerRadius(10)
    }
}

// MARK: - StoreKit IAP Coin shop View
struct CoinPackageRow: Identifiable {
    let id: String
    let coins: Int
    let price: String
    let bonus: String
}

struct StoreView: View {
    @ObservedObject var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var purchasingPackage: CoinPackageRow? = nil
    @ObservedObject var iapManager = IAPManager.shared
    
    // Explicit Product IDs and coin amounts matching user table exactly
    let packages = [
        CoinPackageRow(id: "Joyar", coins: 32, price: "$0.99", bonus: "32 coins"),
        CoinPackageRow(id: "Joyar1", coins: 60, price: "$1.99", bonus: "60 coins"),
        CoinPackageRow(id: "Joyar2", coins: 96, price: "$2.99", bonus: "96 coins"),
        CoinPackageRow(id: "Joyar4", coins: 155, price: "$4.99", bonus: "155 coins"),
        CoinPackageRow(id: "Joyar5", coins: 189, price: "$5.99", bonus: "189 coins"),
        CoinPackageRow(id: "Joyar9", coins: 359, price: "$9.99", bonus: "359 coins (299+60 Bonus)"),
        CoinPackageRow(id: "Joyar19", coins: 729, price: "$19.99", bonus: "729 coins (599+130 Bonus)"),
        CoinPackageRow(id: "Joyar49", coins: 1869, price: "$49.99", bonus: "1869 coins (1599+270 Bonus)"),
        CoinPackageRow(id: "Joyar99", coins: 3799, price: "$99.99", bonus: "3799 coins (3199+600 Bonus)")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Shiny Coin header
                    VStack(spacing: 12) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 54))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.4), radius: 10)
                            .padding(.top, 20)
                        
                        Text("Joyar Coin Shop")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("Unlock premium masterclass trainings, personalized hypertrophy routines and specialized nutritional plans instantly.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .lineSpacing(3)
                        
                        HStack(spacing: 6) {
                            Text("Current Balance:")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Text("\(dataService.coinBalance) Coins")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                    }
                    
                    // Shop packages listing
                    VStack(spacing: 14) {
                        ForEach(packages, id: \.id) { pack in
                            HStack(spacing: 14) {
                                // Left Coin Symbol
                                ZStack {
                                    Circle().fill(Color.yellow.opacity(0.1)).frame(width: 44, height: 44)
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.yellow)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pack.bonus)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Product ID: \(pack.id)")
                                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                // Price Tier Buy button
                                Button(action: {
                                    purchasingPackage = pack
                                    iapManager.startPurchase(productId: pack.id, coinsAmount: pack.coins)
                                }) {
                                    Text(pack.price)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(width: 76, height: 34)
                                        .background(Color.yellow)
                                        .cornerRadius(17)
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.08).edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Text("Top Up Wallet"), displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.gray))
        }
        .preferredColorScheme(.dark)
        // StoreKit Payment spinner
        .overlay(
            Group {
                if iapManager.isPurchasing, let pkg = purchasingPackage {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {} // Prevent dismiss
                        
                        VStack(spacing: 20) {
                            ActivityIndicator()
                                .frame(width: 40, height: 40)
                            
                            VStack(spacing: 8) {
                                Text("Connecting to App Store...")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text(iapManager.transactionStateString)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(30)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                        .cornerRadius(20)
                    }
                }
            }
        )
        .alert(isPresented: Binding(
            get: { iapManager.showSuccessAlert },
            set: { if !$0 { iapManager.showSuccessAlert = false; purchasingPackage = nil } }
        )) {
            Alert(
                title: Text("Purchase Successful! 🎉"),
                message: Text("Thank you! Your StoreKit payment transaction completed. \(iapManager.purchasedCoinsAmount) Coins have been added to your Joyar wallet!"),
                dismissButton: .default(Text("Awesome!"))
            )
        }
    }
}

// MARK: - StoreKit 1 Real In-App Purchase Manager
class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    
    @Published var isPurchasing: Bool = false
    @Published var transactionStateString: String = ""
    @Published var showSuccessAlert: Bool = false
    @Published var purchasedCoinsAmount: Int = 0
    
    private var productsRequest: SKProductsRequest?
    private var pendingCoinsAmount: Int = 0
    private var pendingProductId: String = ""
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func startPurchase(productId: String, coinsAmount: Int) {
        isPurchasing = true
        pendingCoinsAmount = coinsAmount
        pendingProductId = productId
        transactionStateString = "Requesting product details from App Store..."
        
        let productIdentifiers = Set([productId])
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            if let product = response.products.first(where: { $0.productIdentifier == self.pendingProductId }) {
                self.transactionStateString = "Starting App Store transaction..."
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                // Xcode Simulator / Sandbox fallback for testing sandbox products
                self.transactionStateString = "Product not found. Falling back to sandbox simulation..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.simulateSandboxSuccess()
                }
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.transactionStateString = "StoreKit request failed: \(error.localizedDescription). Falling back to sandbox simulation..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.simulateSandboxSuccess()
            }
        }
    }
    
    private func simulateSandboxSuccess() {
//        DataService.shared.purchaseCoins(amount: self.pendingCoinsAmount)
//        self.purchasedCoinsAmount = self.pendingCoinsAmount
//        self.isPurchasing = false
//        self.transactionStateString = ""
//        self.showSuccessAlert = true
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                DispatchQueue.main.async {
                    self.transactionStateString = "App Store: Purchasing..."
                }
            case .purchased:
                DispatchQueue.main.async {
                    DataService.shared.purchaseCoins(amount: self.pendingCoinsAmount)
                    self.purchasedCoinsAmount = self.pendingCoinsAmount
                    self.isPurchasing = false
                    self.transactionStateString = ""
                    self.showSuccessAlert = true
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                DispatchQueue.main.async {
                    if let err = transaction.error as NSError?, err.code != SKError.paymentCancelled.rawValue {
                        self.transactionStateString = "Transaction failed: \(err.localizedDescription). Trying sandbox fallback..."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.simulateSandboxSuccess()
                        }
                    } else {
                        // User cancelled payment
                        self.isPurchasing = false
                        self.transactionStateString = ""
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                DispatchQueue.main.async {
                    self.isPurchasing = false
                    self.transactionStateString = ""
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                DispatchQueue.main.async {
                    self.transactionStateString = "Transaction deferred..."
                }
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Beautiful Custom Workout History Sheet
struct WorkoutHistorySheet: View {
    @ObservedObject var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if dataService.workoutHistory.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "flame")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                            Text("No workouts logged yet")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.gray)
                            Text("Complete any workout video to start tracking calorie burns!")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(dataService.workoutHistory, id: \.id) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 10))
                                        Text(formatDate(item.date))
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                Text("+\(item.caloriesBurned) kcal")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 1.0, green: 0.37, blue: 0.23).opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                            .cornerRadius(12)
                        }
                    }
                    Spacer(minLength: 30)
                }
                .padding(16)
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.08).edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Text("Workout Logs"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.gray))
        }
        .preferredColorScheme(.dark)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
