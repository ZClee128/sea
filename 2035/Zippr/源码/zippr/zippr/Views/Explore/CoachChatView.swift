import Combine
import Foundation
import SwiftUI

// MARK: - Chat Manager for Persistence
@available(iOS 15.0, *)
class ChatManager: ObservableObject {
    static let shared = ChatManager()
    
    @Published var messagesByCoach: [String: [ChatMessage]] = [:]
    @Published var blockedCoaches: Set<String> = []
    
    private init() {
        if let mData = UserDefaults.standard.data(forKey: "Z_Msg_Store"),
           let decodedMsgs = try? JSONDecoder().decode([String: [ChatMessage]].self, from: mData) {
            messagesByCoach = decodedMsgs
        }
        if let bData = UserDefaults.standard.data(forKey: "Z_Block_Store"),
           let decodedBlocks = try? JSONDecoder().decode([String].self, from: bData) {
            blockedCoaches = Set(decodedBlocks)
        }
    }
    
    private func saveSession() {
        if let mData = try? JSONEncoder().encode(messagesByCoach) {
            UserDefaults.standard.set(mData, forKey: "Z_Msg_Store")
        }
        if let bData = try? JSONEncoder().encode(Array(blockedCoaches)) {
            UserDefaults.standard.set(bData, forKey: "Z_Block_Store")
        }
    }
    
    func ensureInit(for coach: String) {
        if messagesByCoach[coach] == nil {
            messagesByCoach[coach] = [
                ChatMessage(id: UUID().uuidString, text: "Hi there! I'm \(coach). Let me know if you have any questions before starting this session.", isCurrentUser: false, timestamp: "Today 10:00 AM")
            ]
            saveSession()
        }
    }
    
    func deleteMessage(_ id: String, for coach: String) {
        messagesByCoach[coach]?.removeAll { $0.id == id }
        saveSession()
    }
    
    func blockUser(coach: String) {
        blockedCoaches.insert(coach)
        messagesByCoach[coach]?.removeAll()
        saveSession()
    }
    
    func sendMessage(_ text: String, to coach: String, isGift: Bool = false) {
        let newMsg = ChatMessage(id: UUID().uuidString, text: text, isCurrentUser: true, timestamp: "Now", isGift: isGift)
        messagesByCoach[coach, default: []].append(newMsg)
        saveSession()
        
        // Mock reply if not blocked
        guard !blockedCoaches.contains(coach) else { return }
        
        // Specialized response for gifts
        let replyText = isGift ? "Wow, thank you so much for the support! Let's crush this together! 🚀" : "Got it! Keep pushing, I'm here if you need anything else."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let reply = ChatMessage(id: UUID().uuidString, text: replyText, isCurrentUser: false, timestamp: "Now")
            withAnimation(.spring()) {
                self.messagesByCoach[coach]?.append(reply)
                self.saveSession()
            }
        }
    }
}

@available(iOS 15.0, *)
struct CoachChatView: View {
    let coachName: String
    @StateObject private var chatManager = ChatManager.shared
    @State private var inputText = ""
    @State private var showReportMessageAlert = false
    @State private var showReportUserAlert = false
    @State private var messageToReport: ChatMessage? = nil
    
    @State private var showGiftSheet = false
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // 自定义顶部导航栏
            chatNavBar
            
            // 聊天区域
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 顶部时间提示
                        Text("Today 9:41 AM")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        if chatManager.blockedCoaches.contains(coachName) {
                            Text("You have blocked this user.")
                                .font(.system(size: 13))
                                .foregroundColor(Color.red.opacity(0.6))
                                .padding(.top, 20)
                        } else {
                            if let coachMessages = chatManager.messagesByCoach[coachName] {
                                ForEach(coachMessages) { msg in
                                    ChatBubbleRow(message: msg, coachName: coachName) { reportedMsg in
                                        // 长按回调举报单条消息
                                        messageToReport = reportedMsg
                                        showReportMessageAlert = true
                                    }
                                }
                            }
                        }
                        
                        // 底部留白，避免输入框遮挡
                        Spacer().frame(height: 20)
                            .id("bottom")
                    }
                    .padding(.horizontal, 16)
                    // 背景区域任意点击、拖拽均可收起键盘
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        hideKeyboard()
                    }
                )
                .onChange(of: chatManager.messagesByCoach[coachName]?.count ?? 0) { _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onAppear {
                    chatManager.ensureInit(for: coachName)
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .background(Color(hex: "#F7F8FA")) // 轻微冷灰色背景，衬托气泡
            
            // 底部输入栏
            if !chatManager.blockedCoaches.contains(coachName) {
                chatInputBar
            }
        }
        .navigationBarHidden(true)
        // 举报消息弹窗确认
        .alert("Report Content", isPresented: $showReportMessageAlert) {
            Button("Report & Delete", role: .destructive) {
                if let msg = messageToReport {
                    withAnimation { chatManager.deleteMessage(msg.id, for: coachName) }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to report and remove this message? Our safety team will review it within 24 hours.")
        }
        // 举报用户弹窗确认
        .alert("Report & Block Coach", isPresented: $showReportUserAlert) {
            Button("Block User", role: .destructive) {
                withAnimation { chatManager.blockUser(coach: coachName) }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to block this user? You will no longer receive messages from them, and their history will be cleared.")
        }
        .sheet(isPresented: $showGiftSheet) {
            GiftSelectionSheet(coachName: coachName)
        }
    }
    
    // MARK: - Navigation Bar
    private var chatNavBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#1D1D2B"))
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(coachName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1D1D2B"))
                Text("Online")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.green)
            }
            
            Spacer()
            
            // 右上角举报用户按钮
            Button {
                showReportUserAlert = true
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#1D1D2B"))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color.white.ignoresSafeArea(edges: .top)) // 修复导航栏过低问题：去除手动 topInset，利用原生 ignoresSafeArea
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .zIndex(10)
    }
    
    // MARK: - Chat Input Bar
    private var chatInputBar: some View {
        HStack(spacing: 12) {
            Button {
                showGiftSheet = true
            } label: {
                Image(systemName: "gift.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FFC107"))
            }
            
            TextField("Message...", text: $inputText)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.04))
                .cornerRadius(20)
            
            if !inputText.isEmpty {
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color(hex: "#E8517A"))
                        .clipShape(Circle())
                        .shadow(color: Color(hex: "#E8517A").opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, safeBottomInset + 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: -4)
    }
    
    // MARK: - Actions
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        chatManager.sendMessage(inputText, to: coachName)
        inputText = "" // 清空
    }
    
    private var safeBottomInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - Chat Bubble Row
@available(iOS 15.0, *)
struct ChatBubbleRow: View {
    let message: ChatMessage
    let coachName: String
    let onReport: (ChatMessage) -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isCurrentUser {
                Spacer(minLength: 50) // 用户气泡挤向右边
                
                // 本人气泡
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 15, weight: message.isGift ? .bold : .regular))
                        .foregroundColor(message.isGift ? Color(hex: "#1D1D2B") : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            message.isGift
                            ? LinearGradient(colors: [Color(hex: "#FFE53B"), Color(hex: "#FF2525").opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color(hex: "#E8517A"), Color(hex: "#FF758C")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(ChatBubbleShape(isCurrentUser: true))
                        .shadow(color: message.isGift ? Color(hex: "#FFE53B").opacity(0.4) : Color(hex: "#E8517A").opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    Text(message.timestamp)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(.trailing, 4)
                }
            } else {
                // 教练头像占位（彩色骨架）
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex: "#43E97B"), Color(hex: "#38F9D7")],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 36, height: 36)
                    Text(coachName.prefix(1).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // 教练气泡
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#1D1D2B"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(ChatBubbleShape(isCurrentUser: false))
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                    
                    Text(message.timestamp)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(.leading, 4)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        onReport(message)
                    } label: {
                        Label("Report / Block", systemImage: "exclamationmark.shield.fill")
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
    }
}

// MARK: - Chat Bubble Shape
struct ChatBubbleShape: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [
                                    .topLeft, .topRight,
                                    isCurrentUser ? .bottomLeft : .bottomRight
                                ],
                                cornerRadii: CGSize(width: 18, height: 18))
        return Path(path.cgPath)
    }
}

// MARK: - Gift Selection component
@available(iOS 15.0, *)
struct GiftSelectionSheet: View {
    let coachName: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coinManager = CoinManager.shared
    @StateObject private var chatManager = ChatManager.shared
    @State private var showInsufficientCoinsAlert = false
    
    // 礼物的金币消耗价格与表情符号
    let gifts = [
        ("Protein Shake", 10, "🥤"),
        ("Golden Dumbbell", 50, "🏋️"),
        ("VIP Session Pass", 150, "👑")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // User Balance
                HStack(spacing: 6) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(Color(hex: "#FFC107"))
                        .font(.system(size: 20))
                    Text("\(coinManager.balance) Coins Available")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.top, 16)
                
                VStack(spacing: 16) {
                    ForEach(gifts, id: \.0) { gift in
                        GiftItemRow(name: gift.0, cost: gift.1, emoji: gift.2) {
                            if coinManager.spendCoins(gift.1) {
                                chatManager.sendMessage("Sent a \(gift.0) \(gift.2)", to: coachName, isGift: true)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                showInsufficientCoinsAlert = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .navigationTitle("Send a Gift")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Not Enough Coins", isPresented: $showInsufficientCoinsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You don't have enough coins to send this gift. Please go to Settings to top up your wallet.")
            }
        }
    }
}

@available(iOS 15.0, *)
struct GiftItemRow: View {
    let name: String
    let cost: Int
    let emoji: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.black.opacity(0.04))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1D1D2B"))
                HStack(spacing: 4) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(Color(hex: "#FFC107"))
                        .font(.system(size: 14))
                    Text("\(cost) Coins")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.gray)
                }
            }
            
            Spacer()
            
            Button(action: onSend) {
                Text("Send")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(LinearGradient(colors: [Color(hex: "#E8517A"), Color(hex: "#FF758C")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "#E8517A").opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}
