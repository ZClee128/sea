import SwiftUI

@available(iOS 15.0, *)
struct ChatView: View {
    let expert: Expert
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var chatManager = ChatSessionManager()
    @State private var messageText = ""
    @State private var showReport = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .onTapGesture {
                    isFocused = false // Dismiss keyboard
                }
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Text(String(expert.name.prefix(1))).bold().foregroundColor(.blue))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(expert.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Expert Study")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { showReport = true }) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red.opacity(0.7))
                            .font(.caption)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(chatManager.messages(for: expert.id)) { msg in
                                ChatBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onTapGesture {
                        isFocused = false // Dismiss keyboard on message list tap
                    }
                    .onChange(of: chatManager.sessions[expert.id]?.count) { _ in
                        if let lastMessage = chatManager.messages(for: expert.id).last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                VStack {
                    Divider().background(Color.white.opacity(0.1))
                    
                    HStack(spacing: 12) {
                        TextField("Ask a technical question...", text: $messageText)
                            .focused($isFocused)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                                .foregroundColor(messageText.isEmpty ? .gray : .blue)
                                .padding(10)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                }
                .background(Color.black)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showReport) {
            ReportView(expertName: expert.name)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatManager.sendMessage(messageText, to: expert)
        messageText = ""
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

@available(iOS 15.0, *)
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.text)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(message.isUser ? Color.blue : Color.white.opacity(0.1))
                .cornerRadius(18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
            
            if !message.isUser { Spacer() }
        }
    }
}

// Rounded corner utility
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
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
