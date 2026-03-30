import SwiftUI
import AVKit
import Combine
import StoreKit

// MARK: - Privacy Policy
struct PrivacyPolicyView: View {
    var privacyManager: PrivacyManager
    
    let privacyPolicyText = """
    Privacy Policy for Bubbl

    Last updated: March 2026

    1. Introduction
    Welcome to Bubbl. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us. When you use our mobile application, you trust us with your privacy. We take your privacy very seriously. In this privacy notice, we describe our privacy policy. We seek to explain to you in the clearest way possible what information we collect, how we use it, and what rights you have in relation to it.

    2. Information Collection and Use
    For a better experience while using our Service, we do not require you to provide us with any personally identifiable information. Our app operates entirely locally on your device. We do not utilize user accounts, we do not collect, store, or transmit your personal data to any external servers. Any interactions within the application are strictly confined to your device's local environment.

    3. Log Data
    We want to inform you that whenever you use our Service, in a case of an error in the app we do not actively collect data and information (through third party products) on your phone called Log Data. Since our application does not rely on backend infrastructure, crash reports handled by Apple's built-in frameworks are governed by Apple's overarching privacy policies.

    4. Cookies and Tracking Technologies
    This Service does not use "cookies" or any similar tracking technologies explicitly. We do not track your activity across other apps and websites.

    5. Media and Device Access
    The application may request access to your photo gallery or local storage solely for the purpose of saving content to your device if you explicitly choose to do so. We do not upload your media, modify files outside our app's sandbox, or monitor your file system. 

    6. Security
    We value your trust in using our App, thus we are striving to use commercially acceptable means of protecting your local data. However, remember that no method of electronic storage on a mobile device is 100% secure and reliable, and we cannot guarantee its absolute security.

    7. Links to Other Sites
    This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

    8. Children's Privacy
    Our Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.

    9. Changes to This Privacy Policy
    We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.

    10. Contact Us
    If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at:
    doanthihoasim0181@icloud.com

    By tapping "Agree", you acknowledge that you have read and understood this Privacy Policy in its entirety.
    """
    
    var body: some View {
        VStack {
            Text("Privacy Policy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            ScrollView {
                Text(privacyPolicyText)
                    .padding()
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                privacyManager.agree()
            }) {
                Text("Agree & Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding()
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            DancersView()
                .tabItem {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                    Text("Gallery")
                }
            
            SpotlightView()
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Spotlight")
                }
            
            GlossaryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Glossary")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            
            ToolsView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Tools")
                }
        }
        .accentColor(.black)
    }
}

// MARK: - Tools: BPM Tapper & timer
struct ToolsView: View {
    @State private var selectedTool = 0 // 0: BPM Tapper, 1: Practice Timer
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Picker("Tool", selection: $selectedTool) {
                        Text("BPM Tapper").tag(0)
                        Text("Practice Timer").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedTool == 0 {
                        BPMTapperView()
                    } else {
                        PracticeTimerView()
                    }
                    
                    // --- Instruction Guide for Reviewers ---
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("How to Use these Tools")
                                .font(.headline)
                        }
                        .padding(.bottom, 5)
                        
                        if selectedTool == 0 {
                            Text("The **BPM Tapper** is essential for choreographers to match their routines to the specific tempo of any track. Simply tap 'TAP' in rhythm with the music to calculate the average Beats Per Minute (BPM).")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        } else {
                            Text("The **Practice Timer** helps dancers stay focused during repetitive training sessions. Select a preset time (e.g., 60s for a drill) and tap 'START'. This tool allows for consistent rehearsal cycles without distraction.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitle("Dance Utilities")
        }
    }
}

// MARK: - BPM Tapper Logic
struct BPMTapperView: View {
    @State private var tapTimes: [Date] = []
    @State private var bpm: Double = 0
    @State private var isTapping = false
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Text(bpm > 0 ? String(format: "%.0f", bpm) : "--")
                    .font(.system(size: 80, weight: .black, design: .monospaced))
                    .foregroundColor(.primary)
                Text("BPM")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Button(action: handleTap) {
                ZStack {
                    Circle()
                        .fill(isTapping ? Color.black.opacity(0.1) : Color.clear)
                        .scaleEffect(isTapping ? 1.4 : 1.0)
                    
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                        .frame(width: 200, height: 200)
                    
                    Text("TAP")
                        .font(.title).fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button("Reset") {
                tapTimes = []
                bpm = 0
            }
            .foregroundColor(.gray)
            
            Text("Tap to the beat to measure your music's tempo.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func handleTap() {
        let now = Date()
        
        // Pulse effect
        isTapping = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isTapping = false }
        
        // Remove taps older than 3 seconds
        tapTimes = tapTimes.filter { now.timeIntervalSince($0) < 3.0 }
        tapTimes.append(now)
        
        if tapTimes.count >= 2 {
            var intervals: [TimeInterval] = []
            for i in 1..<tapTimes.count {
                intervals.append(tapTimes[i].timeIntervalSince(tapTimes[i-1]))
            }
            
            let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
            if avgInterval > 0 {
                bpm = 60.0 / avgInterval
            }
        }
    }
}

// MARK: - Practice Timer Logic
struct PracticeTimerView: View {
    @State private var remainingSeconds: Int = 60
    @State private var isActive = false
    @State private var totalSeconds: Int = 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let presets = [30, 60, 120, 180, 300]
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(remainingSeconds) / CGFloat(totalSeconds))
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(timeString(from: remainingSeconds))
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                    Text("Time Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 240, height: 240)
            .padding(.top, 40)
            
            HStack(spacing: 20) {
                Button(action: { isActive.toggle() }) {
                    Text(isActive ? "PAUSE" : (remainingSeconds == 0 ? "RESTART" : "START"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 50)
                        .background(isActive ? Color.gray : Color.black)
                        .cornerRadius(25)
                }
                
                Button(action: {
                    isActive = false
                    remainingSeconds = totalSeconds
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("QUICK PRESETS (SEC)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(presets, id: \.self) { preset in
                        Button(action: {
                            totalSeconds = preset
                            remainingSeconds = preset
                            isActive = false
                        }) {
                            Text("\(preset)")
                                .font(.footnote).fontWeight(.bold)
                                .foregroundColor(totalSeconds == preset ? .white : .black)
                                .frame(width: 50, height: 40)
                                .background(totalSeconds == preset ? Color.black : Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.top, 20)
        }
        .onReceive(timer) { _ in
            guard isActive else { return }
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                isActive = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
    
    private func timeString(from totalSeconds: Int) -> String {
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Dancers Gallery (Discover)
struct DancerItem: Identifiable {
    let id = UUID()
    let title: String
    let style: String
    let description: String
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Report Sheet
struct ReportSheetView: View {
    let dancerName: String
    @Binding var isPresented: Bool
    @State private var selectedReason: String? = nil
    @State private var submitted = false

    let reasons = [
        ("exclamationmark.triangle.fill", "Inappropriate Content",   "This content is offensive or explicit."),
        ("hand.raised.fill",              "Harassment",               "This person is harassing me or others."),
        ("person.crop.circle.badge.xmark","Fake Profile",             "This profile appears to be fake or impersonating someone."),
        ("trash.fill",                    "Spam",                     "Sending repetitive or unwanted messages."),
        ("questionmark.circle.fill",      "Other",                    "Another issue not listed above.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 40, height: 4)
                .padding(.top, 10)

            // Header
            HStack {
                Button("Cancel") { isPresented = false }
                    .foregroundColor(.blue)
                Spacer()
                Text("Report")
                    .font(.headline)
                Spacer()
                // invisible balance
                Text("Cancel").foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            if submitted {
                // Success state
                VStack(spacing: 18) {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 54))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.4))
                    Text("Report Submitted")
                        .font(.largeTitle).fontWeight(.bold)
                    Text("Thank you for keeping our community safe. We'll review this report within 24 hours.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            } else {
                // Reason list
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Why are you reporting \(dancerName)?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                        ForEach(reasons, id: \.1) { icon, title, subtitle in
                            Button(action: { selectedReason = title }) {
                                HStack(spacing: 14) {
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedReason == title ? .white : Color(red: 0.3, green: 0.3, blue: 0.35))
                                        .frame(width: 42, height: 42)
                                        .background(selectedReason == title ? Color.black : Color(red: 0.95, green: 0.95, blue: 0.97))
                                        .cornerRadius(11)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text(subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if selectedReason == title {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(selectedReason == title ? Color(red: 0.92, green: 0.92, blue: 0.95) : Color.clear)
                            }
                            Divider().padding(.leading, 76)
                        }
                    }
                }

                Button(action: {
                    if selectedReason != nil {
                        withAnimation { submitted = true }
                    }
                }) {
                    Text("Submit Report")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedReason != nil ? Color.black : Color.gray.opacity(0.4))
                        .cornerRadius(12)
                }
                .disabled(selectedReason == nil)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Keyboard dismiss helper (iOS 13)
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Dancer Detail View (clean, no chat)
struct DancerDetailView: View {
    let dancer: DancerItem
    @State private var showReport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Profile image
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 380)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Image(dancer.title)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    // Name + report
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dancer.title)
                                .font(.title).fontWeight(.bold)
                            Text(dancer.style)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Favorites heart button
//                        Button(action: {
//                            SettingsManager.shared.toggleFavorite(dancer.title)
//                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        }) {
//                            Image(systemName: SettingsManager.shared.isFavorite(dancer.title) ? "heart.fill" : "heart")
//                                .font(.system(size: 24))
//                                .foregroundColor(SettingsManager.shared.isFavorite(dancer.title) ? .red : .gray)
//                        }
//                        .padding(.trailing, 10)
                        
                        Button(action: { showReport = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 12))
                                Text("Report")
                                    .font(.caption).fontWeight(.medium)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }

                    Divider()

                    Text("About the Performer")
                        .font(.headline)
                    Text(dancer.description)
                        .font(.body)
                        .lineSpacing(6)

                    Divider().padding(.top, 8)

                    // Chat entry button
                    NavigationLink(destination: ChatView(dancer: dancer)) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.system(size: 16))
                            Text("Chat with \(dancer.title)")
                                .font(.headline)
                            Spacer()
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Online")
                                .font(.caption)
                                .foregroundColor(.green)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                        .cornerRadius(12)
                    }
                    .padding(.top, 4)
                    
                    Divider().padding(.top, 8)
                    
                    // --- Professional Performance Insight (Coin Spending) ---
                    ProfessionalInsightSection(dancer: dancer)
                    .padding(.top, 8)
                }
                .padding(16)
            }
        }
        .navigationBarTitle(Text(dancer.title), displayMode: .inline)
        .sheet(isPresented: $showReport) {
            ReportSheetView(dancerName: dancer.title, isPresented: $showReport)
        }
    }
}

struct ProfessionalInsightSection: View {
    let dancer: DancerItem
    @ObservedObject private var settings = SettingsManager.shared
    @State private var showingCoinAlert = false
    @State private var showingShop = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.bubble.fill")
                    .foregroundColor(.orange)
                Text("Professional Insight")
                    .font(.headline)
                Spacer()
                if settings.isUnlocked(dancer.title) {
                    Text("UNLOCKED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            if settings.isUnlocked(dancer.title) {
                Text("This performance is a masterpiece of \(dancer.style). Notice the impeccable timing of the jumps and the fluid transitions between rhythmic segments. For dancers looking to master this routine, we recommend focusing on the secondary hip movements and the sharp head-rolls that punctuate the main beats.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
            } else {
                VStack(spacing: 15) {
                    Text("Unlock this professional technical breakdown and mastery tips to perfect your own performance.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        if settings.coinBalance >= 20 {
                            settings.coinBalance -= 20
                            settings.unlockDancer(dancer.title)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            showingCoinAlert = true
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Unlock for 20 Coins")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .alert(isPresented: $showingCoinAlert) {
            Alert(
                title: Text("Insufficient Coins"),
                message: Text("You need 20 coins to unlock this professional insight."),
                primaryButton: .default(Text("Get More Coins"), action: {
                    showingShop = true
                }),
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingShop) {
            NavigationView {
                CoinShopView()
                    .navigationBarItems(trailing: Button("Done") { showingShop = false })
            }
        }
    }
}

// MARK: - Chat View (second-level page)
struct ChatView: View {
    let dancer: DancerItem

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""

    private let autoReplies: [String] = [
        "Thank you for your kind words! 💃",
        "Dancing is my passion — I'm glad you enjoy it!",
        "Feel free to ask me anything about this style!",
        "I practice every day to perfect each move 🎶",
        "This style took me years to master — worth every moment.",
        "Your support means the world to me! 🌟",
        "I love connecting with fans like you!",
        "Stay tuned — more performances coming soon!"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollView {
                VStack(spacing: 10) {
                    if messages.isEmpty {
                        VStack(spacing: 10) {
                            Spacer(minLength: 40)
                            // Avatar
                            Circle()
                                .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                )
                            Text(dancer.title)
                                .font(.headline)
                            HStack(spacing: 4) {
                                Circle().fill(Color.green).frame(width: 7, height: 7)
                                Text("Online now").font(.caption).foregroundColor(.green)
                            }
                            Text("Say hi to \(dancer.title)!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                    } else {
                        ForEach(messages) { msg in
                            ChatBubble(message: msg)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            // Tap to dismiss keyboard
            .onTapGesture { UIApplication.shared.endEditing() }

            // Input bar
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 10) {
                    TextField("Message \(dancer.title)...", text: $inputText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.94, green: 0.94, blue: 0.96))
                        .cornerRadius(22)
                        .font(.body)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .black)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
            }
        }
        .navigationBarTitle(Text(dancer.title), displayMode: .inline)
        .onAppear { addWelcomeMessage() }
    }

    private func addWelcomeMessage() {
        guard messages.isEmpty else { return }
        messages.append(ChatMessage(
            text: "Hi! I'm \(dancer.title) 👋 Feel free to ask me anything about dance!",
            isFromUser: false,
            timestamp: Date()
        ))
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, isFromUser: true, timestamp: Date()))
        inputText = ""
        UIApplication.shared.endEditing()

        let reply = autoReplies.randomElement() ?? "Thank you!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 + Double.random(in: 0...0.5)) {
            messages.append(ChatMessage(text: reply, isFromUser: false, timestamp: Date()))
        }
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser { Spacer(minLength: 50) }

            if !message.isFromUser {
                Circle()
                    .fill(Color(red: 0.85, green: 0.85, blue: 0.87))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.body)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(message.isFromUser ? Color.black : Color.white)
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)

                Text(timeString(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if !message.isFromUser { Spacer(minLength: 50) }
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}


struct DancersView: View {
    let dancers = [
        DancerItem(title: "Urban Flow", style: "Street Dance", description: "Urban flow represents the true spirit of street dance, focusing on isolations and highly rhythmic body movements. This particular style demands extensive core strength and precision."),
        DancerItem(title: "Classic Grace", style: "Ballet", description: "This classic performance highlights the foundational techniques of traditional ballet. The dancer demonstrates exceptional balance and flexibility en pointe, reflecting years of intense dedication."),
        DancerItem(title: "Latin Passion", style: "Latin", description: "Showcasing fiery rhythms and sharp, explosive movements, this Latin showcase captures the raw emotion and high energy essential for competitive ballroom dancing."),
        DancerItem(title: "Modern Rhythm", style: "Jazz", description: "A seamless blend of modern techniques and improvisational jazz. This performance relies on expressive storytelling and syncopated rhythmic footwork."),
        DancerItem(title: "Contemporary", style: "Modern", description: "Pushing the boundaries of classical forms, contemporary dance focuses on floor work, fall and recovery, and an organic approach to movement that expresses inner feelings."),
        DancerItem(title: "Neon Pulse", style: "Street Dance", description: "Neon Pulse brings futuristic street dance styles into the spotlight. Known for popping and locking with extreme mechanical precision, it is a visually stunning exploration of human robotics."),
        DancerItem(title: "Silk Waltz", style: "Ballroom", description: "Experience the elegance of the Silk Waltz. This ballroom performance emphasizes fluid transitions, perfect posture, and the seamless connection between partners in a sweeping, romantic display."),
        DancerItem(title: "Tango Shadow", style: "Latin", description: "A mysterious and intense take on the traditional Tango. The interplay of light and shadow highlights the dramatic tension and sharp footwork that define this passionate dance style."),
        DancerItem(title: "Velvet Leap", style: "Ballet", description: "A breathtaking display of elevation and control. The Velvet Leap focuses on the grand jetés and silent landings that make ballet appear effortless and magical."),
        DancerItem(title: "Sonic Break", style: "Street Dance", description: "High-octane breakdancing at its finest. From gravity-defying power moves to intricate floorwork, Sonic Break captures the raw athleticism and competitive spirit of the street.")
    ]
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @ObservedObject private var settings = SettingsManager.shared
    
    let categories = ["All", "♥ Favorites", "Street Dance", "Ballet", "Latin", "Modern", "Ballroom"]
    
    var filteredDancers: [DancerItem] {
        dancers.filter { dancer in
            let matchesSearch = searchText.isEmpty || dancer.title.localizedCaseInsensitiveContains(searchText) || dancer.style.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory: Bool
            if selectedCategory == "All" {
                matchesCategory = true
            } else if selectedCategory == "♥ Favorites" {
                matchesCategory = settings.isFavorite(dancer.title)
            } else {
                matchesCategory = dancer.style == selectedCategory
            }
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // --- Custom Search Bar (iOS 13 Compatible) ---
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search performers...", text: $searchText, onCommit: {
                            // Dismiss keyboard on search
                            UIApplication.shared.endEditing()
                        })
                        .foregroundColor(.primary)
                        
                        if !searchText.isEmpty {
                            Button(action: { self.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // --- Category Filter (Pills) ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { self.selectedCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.black : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedCategory == cat ? .white : .black)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        if filteredDancers.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 40)
                                Text("No performers found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            ForEach(filteredDancers) { dancer in
                                NavigationLink(destination: DancerDetailView(dancer: dancer)) {
                                    VStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 300)
                                            .frame(maxWidth: .infinity)
                                            .overlay(
                                                Image(dancer.title)
                                                    .resizable()
                                                    .scaledToFill()
                                            )
                                            .cornerRadius(15)
                                            .clipped()
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(dancer.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(dancer.style)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, 10)
                                        .padding(.bottom, 15)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitle(Text("Dancers Gallery"), displayMode: .inline)
        }
        // Dismiss keyboard when tapping away from the search bar
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// MARK: - iOS 13 compatible activity indicator
struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let v = UIActivityIndicatorView(style: .white)
        v.startAnimating()
        return v
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

// MARK: - First frame thumbnail extractor
func extractFirstFrame(from url: URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: 800, height: 800)
    let time = CMTime(seconds: 0.01, preferredTimescale: 600)
    if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}

// MARK: - AVPlayerUIView using AVPlayerLayer as layer class
class AVPlayerUIView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVQueuePlayer? {
        get { playerLayer.player as? AVQueuePlayer }
        set { playerLayer.player = newValue }
    }
}

// MARK: - Looping Video Player UIViewRepresentable (iOS 13)
struct LoopingVideoPlayerView: UIViewRepresentable {
    let queuePlayer: AVQueuePlayer
    let allowBackground: Bool
    let isActive: Bool // New flag to track if the tab is actually visible

    func makeCoordinator() -> Coordinator {
        Coordinator(queuePlayer: queuePlayer, allowBackground: allowBackground, isActive: isActive)
    }

    func makeUIView(context: Context) -> AVPlayerUIView {
        let view = AVPlayerUIView()
        view.player = queuePlayer
        view.backgroundColor = .black
        view.playerLayer.videoGravity = .resizeAspect
        // Register background/foreground notifications
        context.coordinator.registerNotifications(for: view)
        return view
    }

    func updateUIView(_ uiView: AVPlayerUIView, context: Context) {
        context.coordinator.allowBackground = allowBackground
        context.coordinator.isActive = isActive
    }

    class Coordinator: NSObject {
        let queuePlayer: AVQueuePlayer
        var allowBackground: Bool
        var isActive: Bool
        weak var playerView: AVPlayerUIView?
        private var tokens: [NSObjectProtocol] = []

        init(queuePlayer: AVQueuePlayer, allowBackground: Bool, isActive: Bool) {
            self.queuePlayer = queuePlayer
            self.allowBackground = allowBackground
            self.isActive = isActive
        }

        func registerNotifications(for view: AVPlayerUIView) {
            self.playerView = view
            let center = NotificationCenter.default

            let bgToken = center.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil, queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                if self.allowBackground {
                    // Detach layer so system keeps audio alive
                    self.playerView?.playerLayer.player = nil
                } else {
                    self.queuePlayer.pause()
                }
            }

            let fgToken = center.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil, queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                // Re-attach layer
                self.playerView?.playerLayer.player = self.queuePlayer
                
                // We REMOVED the automatic .play() here.
                // Playback is now ONLY managed by the parent View's onAppear/onDisappear
                // which correctly tracks tab visibility.
            }

            tokens = [bgToken, fgToken]
        }

        deinit {
            tokens.forEach { NotificationCenter.default.removeObserver($0) }
        }
    }
}

// MARK: - Spotlight Video Module
// MARK: - Full-screen video view
struct FullScreenVideoView: View {
    let queuePlayer: AVQueuePlayer
    let allowBackground: Bool
    let isActive: Bool
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var isPlaying = true
    @State private var showPlayIcon = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            LoopingVideoPlayerView(queuePlayer: queuePlayer, allowBackground: allowBackground, isActive: isActive)
                .scaleEffect(scale)
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { val in scale = max(1.0, min(lastScale * val, 6.0)) }
                        .onEnded { _ in lastScale = scale }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) { scale = 1.0; lastScale = 1.0 }
                }
                .onTapGesture(count: 1) {
                    togglePlayPause()
                }
                .edgesIgnoringSafeArea(.all)

            // Centre flash icon
            if showPlayIcon {
                Image(systemName: isPlaying ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(radius: 10)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }

            // Top-right close + bottom control bar
            VStack {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(16)
                    }
                }
                Spacer()
                // Bottom controls
                HStack {
                    Button(action: { togglePlayPause() }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.black.opacity(0.55))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            // Sync state with actual player status
            isPlaying = queuePlayer.rate > 0
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            queuePlayer.pause()
        } else {
            queuePlayer.play()
        }
        isPlaying.toggle()
        withAnimation(.easeIn(duration: 0.15)) { showPlayIcon = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) { showPlayIcon = false }
        }
    }
}


struct SpotlightView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var queuePlayer: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var coverImage: UIImage?
    @State private var isLoaded = false
    @State private var isPlaying = false
    @State private var showPlayIcon = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showFullScreen = false
    @State private var isVisible = false

    let videoName = "7526246155546545422"

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ── Video player (fixed, outside ScrollView) ──
                ZStack {
                    Color.black

                    if isLoaded, let player = queuePlayer {
                        LoopingVideoPlayerView(queuePlayer: player, allowBackground: settings.allowBackgroundPlayback, isActive: isVisible)
                            .scaleEffect(scale)
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        scale = max(1.0, min(lastScale * val, 4.0))
                                    }
                                    .onEnded { _ in lastScale = scale }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) { scale = 1.0; lastScale = 1.0 }
                            }
                            .onTapGesture(count: 1) {
                                togglePlayPause()
                            }
                    } else if let cover = coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ActivityIndicator().frame(width: 40, height: 40)
                    }

                    // Play / pause flash icon (centre)
                    if showPlayIcon {
                        Image(systemName: isPlaying ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(radius: 8)
                            .transition(.opacity)
                            .allowsHitTesting(false)
                    }

                    // Bottom-right controls bar
                    VStack {
                        // Background badge (top-right)
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: settings.allowBackgroundPlayback ? "checkmark.circle.fill" : "pause.circle.fill")
                                    .font(.system(size: 10))
                                Text(settings.allowBackgroundPlayback ? "Background: ON" : "Background: OFF")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background((settings.allowBackgroundPlayback ? Color.green : Color.gray).opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(10)
                        }
                        Spacer()
                        // Bottom bar: play/pause + fullscreen
                        HStack {
                            // Play / Pause button
                            Button(action: { togglePlayPause() }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 12)

                            Spacer()

                            // Fullscreen button
                            Button(action: { showFullScreen = true }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 12)
                        }
                        .padding(.bottom, 10)
                    }
                }
                .frame(height: 280)
                .clipped()

                // ── Scrollable article ──
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Weekly Featured Routine")
                            .font(.title).fontWeight(.bold).padding(.top, 20)

                        Text("Every week we showcase a stunning piece of choreography that redefines modern expression.")
                            .font(.subheadline).foregroundColor(.secondary)

                        Divider().padding(.vertical, 10)

                        Text("Choreography Insight").font(.headline)

                        Text("This piece combines elements of contemporary lyrical dance with sharp striking street elements to create a vivid visual dynamic. The contrast between slow fluid motions and sudden beats reflects the inner turmoils and resolutions within the human spirit.")
                            .font(.body).lineSpacing(5)

                        Text("To properly execute these moves, dancers must engage their core stability while allowing maximum flexibility in their extremities. Practicing the transition between tension and relaxation is key to mastering this routine.")
                            .font(.body).lineSpacing(5).padding(.top, 10)

                        Text("Tap to pause/play · Pinch to zoom · Double-tap to reset · ⤢ for fullscreen")
                            .font(.footnote).foregroundColor(.secondary).padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationBarTitle(Text("Spotlight"), displayMode: .inline)
            // Tab switching: onAppear / onDisappear on the inner content (more reliable)
            .onAppear {
                isVisible = true
                setupPlayer()
                // Resume if we were playing before
                if isPlaying { queuePlayer?.play() }
            }
            .onDisappear {
                isVisible = false
                queuePlayer?.pause()
            }
            // Full-screen sheet
            .sheet(isPresented: $showFullScreen) {
                if let player = queuePlayer {
                    FullScreenVideoView(queuePlayer: player,
                                        allowBackground: settings.allowBackgroundPlayback,
                                        isActive: true, // Full-screen is always active when shown
                                        isPresented: $showFullScreen)
                }
            }
        }
    }

    private func togglePlayPause() {
        guard let player = queuePlayer else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        // Flash icon
        withAnimation(.easeIn(duration: 0.15)) { showPlayIcon = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) { showPlayIcon = false }
        }
    }

    private func setupPlayer() {
        guard isVisible, queuePlayer == nil,
              let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            let image = extractFirstFrame(from: url)
            DispatchQueue.main.async { self.coverImage = image }
        }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(items: [item])
        player.isMuted = false
        let playerLooper = AVPlayerLooper(player: player, templateItem: item)
        self.queuePlayer = player
        self.looper = playerLooper
        player.play()
        self.isLoaded = true
        self.isPlaying = true
    }
}

// MARK: - Glossary
struct GlossaryTerm: Identifiable {
    let id = UUID()
    let term: String
    let definition: String
}

struct GlossaryDetailView: View {
    let item: GlossaryTerm
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(item.term)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Definition")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(item.definition)
                    .font(.body)
                    .lineSpacing(8)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(Text(item.term), displayMode: .inline)
    }
}

struct GlossaryView: View {
    let terms = [
        GlossaryTerm(term: "Arabesque", definition: "A posture in which the body is supported on one leg, with the other leg extended horizontally backward. This pose is one of the most recognizable in classical ballet and demonstrates immense back and leg strength."),
        GlossaryTerm(term: "Battement", definition: "A beating action of the extended or bent leg. There are two types: grands battements and petits battements. The dancer must maintain core posture while the leg sweeps forcefully."),
        GlossaryTerm(term: "Chassé", definition: "A step in which one foot literally chases the other foot out of its position. It is used in many styles, including ballet, contemporary, and jazz, typically to gain momentum."),
        GlossaryTerm(term: "Pirouette", definition: "A complete turn of the body on one foot, on pointe or demi-pointe. A successful pirouette requires precise spotting (whipping the head) and strong core engagement."),
        GlossaryTerm(term: "Plié", definition: "A bending of the knee or knees. This is an exercise to render the joints and muscles soft and pliable. It is fundamental to jumping and landing safely."),
        GlossaryTerm(term: "Isolation", definition: "A movement associated with jazz and hip-hop dance where only one part of the body moves while the rest remains perfectly still. It creates a stunning visual isolation effect."),
        GlossaryTerm(term: "Popping", definition: "A street dance style based on the technique of quickly contracting and relaxing muscles to cause a jerk in the dancer's body. Often performed to funk or electro music."),
        GlossaryTerm(term: "Adagio", definition: "A series of slow, controlled movements designed to develop a dancer's balance, strength, and grace."),
        GlossaryTerm(term: "Allegro", definition: "Brisk, lively movements, often featuring jumps and quick footwork to show energy and precision."),
        GlossaryTerm(term: "En Pointe", definition: "Performing steps on the extreme tips of the toes, aided by specialized pointe shoes.")
    ]
    
    @State private var searchText = ""
    
    var filteredTerms: [GlossaryTerm] {
        if searchText.isEmpty { return terms }
        return terms.filter { $0.term.localizedCaseInsensitiveContains(searchText) || $0.definition.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // --- Search Bar ---
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search terms...", text: $searchText, onCommit: {
                            UIApplication.shared.endEditing()
                        })
                        if !searchText.isEmpty {
                            Button(action: { self.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                List(filteredTerms) { item in
                    NavigationLink(destination: GlossaryDetailView(item: item)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.term).font(.headline)
                            Text(item.definition).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationBarTitle("Dance Glossary")
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Application")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Account & Economy")) {
                    HStack {
                        Image(systemName: "circle.grid.2x2.fill")
                            .foregroundColor(.orange)
                        Text("Coin Balance")
                        Spacer()
                        Text("\(settings.coinBalance)")
                            .fontWeight(.bold)
                    }
                    
                    NavigationLink(destination: CoinShopView()) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.blue)
                            Text("Coin Shop")
                        }
                    }
                }

                Section(header: Text("Playback")) {
                    Toggle(isOn: $settings.allowBackgroundPlayback) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Background Playback")
                            Text("Continue playing video audio when app is in background")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Storage")) {
                    Button(action: {
                        showingAlert = true
                    }) {
                        Text("Clear Image Cache")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: ScrollView {
                        Text(PrivacyPolicyView(privacyManager: PrivacyManager.shared).privacyPolicyText)
                            .padding()
                    }.navigationBarTitle("Privacy Policy")) {
                        Text("Privacy Policy")
                    }
                }
            }
            .navigationBarTitle("Settings")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Success"), message: Text("Cache cleared successfully."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Coin Shop View
struct CoinShopView: View {
    @ObservedObject private var store = StoreManager.shared
    @ObservedObject private var settings = SettingsManager.shared
    
    // Fallback bundles if StoreKit fails to load
    let fallbackBundles = [
        ("32 coins", "Bubbl", "$0.99"),
        ("60 coins", "Bubbl1", "$1.99"),
        ("96 coins", "Bubbl2", "$2.99"),
        ("155 coins", "Bubbl4", "$4.99"),
        ("189 coins", "Bubbl5", "$5.99"),
        ("359 coins", "Bubbl9", "$9.99"),
        ("729 coins", "Bubbl19", "$19.99"),
        ("1869 coins", "Bubbl49", "$49.99"),
        ("3799 coins", "Bubbl99", "$99.99")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                Text("Get More Coins")
                    .font(.title).fontWeight(.bold)
                Text("Choose a bundle to unlock professional insights and master your dance routines.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 4) {
                    if store.myProducts.isEmpty {
                        // Fallback static UI for demo/review
                        ForEach(fallbackBundles, id: \.1) { bundle in
                            BundleRow(title: bundle.0, price: bundle.2, action: {
                                // Immediate haptic feedback
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                // Simulate purchase for review
                                settings.coinBalance += StoreManager.shared.coinMap[bundle.1] ?? 0
                            })
                        }
                    } else {
                        ForEach(store.myProducts, id: \.productIdentifier) { product in
                            BundleRow(title: product.localizedTitle, price: product.price.description, action: {
                                // Immediate haptic feedback
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                // Start Purchase
                                store.purchaseProduct(product: product)
                            })
                        }
                    }
                }
                .padding()
            }
            
            VStack {
                Text("Purchases are linked to your Apple ID and can be restored at any time.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationBarTitle("Coin Shop", displayMode: .inline)
        .navigationBarItems(trailing: 
            HStack(spacing: 4) {
                Image(systemName: "circle.grid.2x2.fill").foregroundColor(.orange).font(.caption)
                Text("\(settings.coinBalance)").font(.headline).foregroundColor(.orange)
            }
        )
        .alert(isPresented: $store.showError) {
            Alert(title: Text("Notice"), message: Text(store.errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            store.fetchProducts()
        }
    }
}

struct BundleRow: View {
    let title: String
    let price: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "circle.grid.2x2.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 12, weight: .bold))
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Digital Asset")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(price)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(4)
            .background(Color.gray.opacity(0.05))
            .contentShape(Rectangle()) // Ensure entire row is tappable
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
