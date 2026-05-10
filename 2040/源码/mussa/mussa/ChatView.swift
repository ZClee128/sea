import SwiftUI

@available(iOS 14.0, *)
struct ChatView: View {
    let muse: AuraItem
    @StateObject var chatManager: ChatManager
    @State private var messageText = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showingReport = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left").font(.title3).foregroundColor(.primary)
                }
                
                ChatAvatarView(muse: muse, isOfficial: muse.id.contains("official"), size: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(muse.museName).font(.headline)
                    Text(muse.id.contains("official") ? "Official Account" : "Resonating with \(muse.crystalType)").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                
                // Report Button in Chat Header
                Button(action: { showingReport = true }) {
                    Image(systemName: "exclamationmark.bubble").font(.title3).foregroundColor(.gray)
                }
            }
            .padding().background(BlurView(style: .systemUltraThinMaterial))
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        // Introduction message
                        VStack(alignment: .leading, spacing: 8) {
                            Text(muse.id.contains("official") ? "Official secure channel with \(muse.museName)." : "This is the beginning of your ethereal connection with \(muse.museName).")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top)
                        }
                        
                        ForEach(chatManager.conversations[muse.id] ?? []) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        
                        Spacer().frame(height: 20).id("bottom")
                    }
                    .padding(.horizontal)
                    .contentShape(Rectangle()) 
                }
                .onChange(of: chatManager.conversations[muse.id]?.count) { _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onAppear {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Message \(muse.museName)...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5))
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingReport) {
            ReportView(targetName: muse.museName)
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        chatManager.sendMessage(text, to: muse)
        messageText = ""
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Chat Specific Avatar (Non-local image)

struct ChatAvatarView: View {
    let muse: AuraItem
    let isOfficial: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isOfficial {
                Circle()
                    .fill(officialColor.opacity(0.1))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: getSymbol(for: muse.id))
                            .foregroundColor(officialColor)
                            .font(.system(size: size * 0.45, weight: .bold))
                    )
            } else {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(String(muse.museName.prefix(1)))
                            .font(.system(size: size * 0.45, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    private func getSymbol(for id: String) -> String {
        if id.contains("official") { return "bell.fill" }
        if id.contains("support") { return "lifepreserver.fill" }
        if id.contains("guide") { return "book.closed.fill" }
        return "person.fill"
    }
    
    private var officialColor: Color {
        if muse.id.contains("official") { return .blue }
        if muse.id.contains("support") { return .orange }
        if muse.id.contains("guide") { return .purple }
        return .blue
    }
}

struct ChatBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromUser ? Color.blue : Color.white)
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(18)
                .cornerRadius(message.isFromUser ? 18 : 18, corners: message.isFromUser ? [.topLeft, .bottomLeft, .topRight] : [.topRight, .bottomRight, .topLeft])
                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            
            if !message.isFromUser { Spacer() }
        }
    }
}
