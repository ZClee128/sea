//
//  ChatView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct ChatView: View {
    let friendName: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var chatManager = VibbleChatManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var messageText = ""
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
                .onTapGesture { 
                    UIApplication.shared.endEditing()
                }
            
            VStack(spacing: 0) {
                // 1. 顶部导航
                HStack(spacing: 15) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Circle()
                        .fill(Theme.Gradients.primaryGradient)
                        .frame(width: 35, height: 35)
                        .overlay(Text(String(friendName.dropFirst().prefix(1))).foregroundColor(.white).font(.caption.bold()))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(friendName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("Online").font(.system(size: 10)).foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: FeedbackView(title: "Report User")) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .foregroundColor(.red.opacity(0.8))
                            .font(.system(size: 18))
                    }
                }
                .padding()
                .background(Theme.cardBackground.opacity(0.8))
                
                // 2. 聊天区域
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Chat History")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(.vertical, 10)
                            
                            let messages = chatManager.getMessages(for: friendName)
                            
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .onTapGesture { 
                        UIApplication.shared.endEditing() 
                    }
                    .onChange(of: chatManager.chatHistory[friendName]?.count) { _ in
                        if let lastId = chatManager.chatHistory[friendName]?.last?.id {
                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                }
                
                // 3. 底部输入框
                HStack(spacing: 12) {
                    TextField("Message...", text: $messageText)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Theme.cardBackground)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(messageText.isEmpty ? .gray : Theme.primary)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                .background(Theme.cardBackground.opacity(0.5))
            }
        }
        .navigationBarHidden(true)
    }
    
    private func sendMessage() {
        chatManager.sendMessage(messageText, to: friendName)
        messageText = ""
    }
}

// 辅助视图
struct CornerRadiusShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

@available(iOS 14.0, *)
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromMe { Spacer() }
            
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromMe ? AnyView(Theme.Gradients.primaryGradient) : AnyView(Theme.cardBackground))
                .foregroundColor(.white)
                .font(.system(size: 15, weight: message.text.contains("🎁") ? .bold : .regular))
                .cornerRadius(18)
                .shadow(radius: 2)
            
            if !message.isFromMe { Spacer() }
        }
    }
}
