import SwiftUI
internal import Combine

struct JunipMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

@available(iOS 14.0, *)
struct JunipConciergeView: View {
    @EnvironmentObject var navState: JunipNavigationState
    let stylistName: String
    
    @State private var messages: [JunipMessage] = []
    @State private var inputText: String = ""
    @State private var isTyping = false
    
    // Reporting states
    @State private var showingReportOptions = false
    @State private var isReported = false
    
    init(stylistName: String = "Style Concierge") {
        self.stylistName = stylistName
    }
    
    private var storageKey: String {
        "junip_chat_\(stylistName.replacingOccurrences(of: " ", with: "_"))"
    }
    
    var body: some View {
        ZStack {
            AppTheme.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                chatScrollView
                
                quickActionsView
                
                inputArea
            }
            
            // Custom Reporting Modal
            if showingReportOptions {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showingReportOptions = false }
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    Text("Report Content")
                        .font(AppTheme.titleSemiBold(size: 20))
                        .padding(.top)
                    
                    Text("Select a reason for reporting \(stylistName).")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        ReportOptionButton(title: "Inappropriate Content") { submitReport() }
                        ReportOptionButton(title: "Spam or Advertising") { submitReport() }
                        ReportOptionButton(title: "Harassment") { submitReport() }
                        
                        Button(action: { showingReportOptions = false }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top)
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 40)
                .shadow(radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Success Message Overlay
            if isReported {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Report Submitted")
                        .font(.headline)
                    
                    Text("Thank you for helping us keep Junip safe. We will review this within 24 hours.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button("OK") { isReported = false }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
        }
        .navigationTitle(stylistName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation { showingReportOptions = true }
                }) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .onAppear(perform: loadHistory)
    }
    
    private func submitReport() {
        withAnimation {
            showingReportOptions = false
            isReported = true
        }
    }
    
    private var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 15) {
                    if messages.isEmpty {
                        welcomeView
                    }
                    
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    if isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }
            .onChange(of: messages.count) { _ in
                withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 50)
            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary)
            
            Text("Hi! I'm \(stylistName). How can I assist your style journey today?")
                .font(AppTheme.titleSemiBold(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("I've reviewed your interest in this look. Ready to curate your routine.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
    }
    
    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickActionChip(title: "Dry hair tips") { sendMessage("How can I fix my dry hair?") }
                QuickActionChip(title: "Summer trends") { sendMessage("What are the latest summer trends?") }
                QuickActionChip(title: "Product help") { sendMessage("I need help with product choices.") }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: $inputText)
                .padding(12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 2)
            
            Button(action: {
                if !inputText.trimmingCharacters(in: .whitespaces).isEmpty {
                    sendMessage(inputText)
                    inputText = ""
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white)
    }
    
    private func sendMessage(_ content: String) {
        let userMsg = JunipMessage(id: UUID(), content: content, isFromUser: true, timestamp: Date())
        messages.append(userMsg)
        saveHistory()
        hideKeyboard() // Dismiss keyboard after send
        
        // Simulate Expert response
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            let response = generateResponse(to: content)
            let expertMsg = JunipMessage(id: UUID(), content: response, isFromUser: false, timestamp: Date())
            messages.append(expertMsg)
            saveHistory()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func generateResponse(to query: String) -> String {
        let lowerQuery = query.lowercased()
        
        // Comprehensive Hair Expert Knowledge Base
        let responses: [String: [String]] = [
            "dry": [
                "For dry texture, we recommend our Hydra-Silk treatment. Check the Lab for a custom moisture sequence!",
                "Deep hydration is key. Have you tried a weekly silk-protein mask? Our experts suggest the 'Moisture Restore' guide in Mastery.",
                "Dryness often stems from heat. Try the Heat Guard booster in your next Lab session for protection."
            ],
            "oily": [
                "Oily scalp can be balanced with a clarifying base. Our Lab's 'Reset Core' is designed specifically for this.",
                "Try spacing out your washes. Our 'Scalp Health 101' article in Mastery hub has great tips on oil regulation.",
                "Avoid heavy oils near the roots. A lightweight Volumize base can help lift strands and reduce oil buildup."
            ],
            "color": [
                "To preserve color, always use sulfate-free sequences. Our Lab formulas are 100% color-safe.",
                "UV rays are the enemy of vibrant color. Check out our 'Summer Care' guide in the Mastery section.",
                "Consider a gloss treatment between salon visits. Our 'Shine Serum' booster adds that professional finish."
            ],
            "trend": [
                "Soft, 'lived-in' waves are very in this season. See our 'Mastering the Wave' tutorial!",
                "We are seeing a return to high-gloss, sleek finishes. Our 'Glass Hair' article covers how to achieve this.",
                "Bold accessories like silk scarves are trending. They pair perfectly with the styles in our Feed."
            ],
            "wash": [
                "Frequency depends on your DNA profile. Generally, 2-3 times a week is optimal for most textures.",
                "Always do a double-cleanse if you use heavy styling products. It ensures the scalp stays healthy.",
                "The water temperature matters! A cool rinse at the end helps seal the hair cuticle for maximum shine."
            ],
            "hi": ["Hello! I am your Junip Style Concierge. I can help with styling tips, product choices, or navigating our Mastery Hub.", "Welcome! Ready to explore some new hair trends today?"],
            "hello": ["Hello! I am your Junip Style Concierge. I can help with styling tips, product choices, or navigating our Mastery Hub.", "Welcome back! How can I assist your style journey today?"]
        ]
        
        // Find matching intent
        for (key, possibleResponses) in responses {
            if lowerQuery.contains(key) {
                return possibleResponses.randomElement() ?? possibleResponses[0]
            }
        }
        
        // Smart Fallback Menu for "Random" queries
        let fallbacks = [
            "I'm dedicated to providing professional hair styling and care advice. Would you like to explore tips for:\n• Dry or Damaged Hair\n• Summer Styling Trends\n• DNA Sequence Mixing?",
            "Our expertise is limited to premium style consultation. I'm not familiar with that request, but I can guide you through our Mastery Hub tutorials!",
            "To give you the best advice, I focus on hair health and trends. Try asking me about 'Color Protection' or 'Wash Routines'!",
            "It looks like we're off-track! Let's get back to your style journey. Have you checked out your custom Formula ID in the Style Lab yet?",
            "Junip is here for your hair goals. For more specific help, try asking about 'dry hair' or 'styling trends'!"
        ]
        
        return fallbacks.randomElement() ?? fallbacks[0]
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([JunipMessage].self, from: data) {
            messages = decoded
        } else {
            messages = []
        }
    }
}

struct MessageBubble: View {
    let message: JunipMessage
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            Text(message.content)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromUser ? AppTheme.primary : Color.white)
                .foregroundColor(message.isFromUser ? .white : AppTheme.secondary)
                .cornerRadius(18, corners: message.isFromUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            
            if !message.isFromUser { Spacer() }
        }
    }
}

struct ReportOptionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.05))
                .cornerRadius(12)
        }
    }
}

struct QuickActionChip: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .foregroundColor(AppTheme.primary)
                .overlay(
                    Capsule().stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                )
        }
        .clipShape(Capsule())
    }
}

struct TypingIndicator: View {
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Expert is curating")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(String(repeating: ".", count: dotCount))
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 20, alignment: .leading)
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
        .padding(.leading, 10)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
