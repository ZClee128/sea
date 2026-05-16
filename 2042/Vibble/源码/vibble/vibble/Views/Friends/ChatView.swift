//
//  ChatView.swift
//  vibble
//

import SwiftUI

struct GiftItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let price: Int
}

@available(iOS 14.0, *)
struct ChatView: View {
    let friendName: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var chatManager = VibbleChatManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var messageText = ""
    @State private var showGiftPanel = false
    @State private var showLowBalanceAlert = false
    @State private var navigateToStore = false
    
    let gifts = [
        GiftItem(name: "Rose", icon: "🌹", price: 50),
        GiftItem(name: "Heart", icon: "❤️", price: 99),
        GiftItem(name: "Diamond", icon: "💎", price: 199),
        GiftItem(name: "Crown", icon: "👑", price: 520),
        GiftItem(name: "Sports Car", icon: "🏎️", price: 999),
        GiftItem(name: "Rocket", icon: "🚀", price: 1314),
        GiftItem(name: "Star", icon: "🌟", price: 30),
        GiftItem(name: "Champagne", icon: "🍾", price: 888)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
                .onTapGesture { 
                    UIApplication.shared.endEditing()
                    if showGiftPanel { withAnimation { showGiftPanel = false } }
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
                        if showGiftPanel { withAnimation { showGiftPanel = false } }
                    }
                    .onChange(of: chatManager.chatHistory[friendName]?.count) { _ in
                        if let lastId = chatManager.chatHistory[friendName]?.last?.id {
                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                }
                
                // 3. 底部输入框
                HStack(spacing: 12) {
                    Button(action: { 
                        UIApplication.shared.endEditing()
                        withAnimation(.spring()) { showGiftPanel.toggle() } 
                    }) {
                        Image(systemName: showGiftPanel ? "gift.circle.fill" : "gift.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.primary)
                    }
                    
                    TextField("Message...", text: $messageText)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Theme.cardBackground)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .onTapGesture {
                            if showGiftPanel { withAnimation { showGiftPanel = false } }
                        }
                    
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
            
            // 4. 自定义礼物面板
            if showGiftPanel {
                ZStack {
                    Color.black.opacity(0.01)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showGiftPanel = false } }
                    
                    VStack {
                        Spacer()
                        CustomGiftPanel(gifts: gifts, balance: authManager.coinsCount) { gift in
                            sendGift(gift)
                        }
                        .transition(.move(edge: .bottom))
                    }
                    .ignoresSafeArea()
                }
                .zIndex(100)
            }
            
            // 隐形的跳转链接
            if #available(iOS 15.0, *) {
                NavigationLink(destination: CoinStoreView(), isActive: $navigateToStore) {
                    EmptyView()
                }
            } else {
                // Fallback on earlier versions
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showLowBalanceAlert) {
            Alert(
                title: Text("Insufficient Balance"),
                message: Text("You don't have enough coins. Please top up to send gifts."),
                primaryButton: .default(Text("Top Up")) {
                    navigateToStore = true
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func sendMessage() {
        chatManager.sendMessage(messageText, to: friendName)
        messageText = ""
    }
    
    private func sendGift(_ gift: GiftItem) {
        if authManager.coinsCount >= gift.price {
            authManager.coinsCount -= gift.price
            chatManager.sendMessage("🎁 Sent you a \(gift.icon) \(gift.name)!", to: friendName)
            withAnimation { showGiftPanel = false }
        } else {
            showLowBalanceAlert = true
        }
    }
}

@available(iOS 14.0, *)
struct CustomGiftPanel: View {
    let gifts: [GiftItem]
    let balance: Int
    let onSelect: (GiftItem) -> Void
    
    private let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 4)
                .padding(.top, 10)
            
            HStack {
                Text("Send a Gift").font(.headline).foregroundColor(.white)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill").foregroundColor(.yellow).font(.system(size: 8))
                    Text("\(balance)").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.1)).cornerRadius(15)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(gifts) { gift in
                        Button(action: { onSelect(gift) }) {
                            VStack(spacing: 8) {
                                Text(gift.icon).font(.system(size: 40))
                                Text(gift.name).font(.system(size: 12)).foregroundColor(.white)
                                Text("\(gift.price) Coins").font(.system(size: 10, weight: .bold)).foregroundColor(Theme.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Theme.cardBackground.opacity(0.5))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 350)
            
            // 关键修复：增加底部 Padding 躲开 Tabbar
            Spacer().frame(height: 90) 
        }
        .background(
            Color(hex: "121212").opacity(0.95)
                .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                .cornerRadius(30, corners: [.topLeft, .topRight])
        )
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: -10)
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
