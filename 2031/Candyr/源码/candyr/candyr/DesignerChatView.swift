import SwiftUI
import Combine
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date = Date()
}

class ChatManager: ObservableObject {
    @Published var messages: [Message] = [
        Message(text: "Hello! I'm the lead designer for Candyr. How can I help you today?", isFromUser: false)
    ]
    
    private let designerReplies = [
        "That's a great question! This collection was inspired by neon-lit cityscapes. We use sustainable digital fabrics for our designs.",
        "We prioritize fluidity and structure in our digital couture. What part of the silhouette interests you most?",
        "The lighting on that specific piece is designed to mimic cyber-punk aesthetics. It's one of our most complex neural renders.",
        "Fashion is evolving, and we think digital-only assets are the future. Our team spent weeks on those silk textures!",
        "Each piece in the gallery is a unique exploration of futuristic style. We love pushing the boundaries of what's possible.",
        "Thank you for sharing your thoughts! We always value artistic feedback from our early collectors."
    ]
    
    func sendMessage(_ text: String) {
        let newUserMessage = Message(text: text, isFromUser: true)
        messages.append(newUserMessage)
        
        // Randomize response delay and content
        let delay = Double.random(in: 1.0...2.5)
        let reply = designerReplies.randomElement() ?? designerReplies[0]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let response = Message(text: reply, isFromUser: false)
            self.messages.append(response)
        }
    }
}

@available(iOS 14.0, *)
struct DesignerChatView: View {
    @ObservedObject var chatManager = ChatManager()
    @State private var newMessageText: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var coinManager = CoinManager.shared
    @State private var showingLowBalanceAlert = false
    @State private var showingReport = false
    @State private var showReportSuccess = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(NeonCouture.primary)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Designer Chat")
                        .font(.headline)
                        .foregroundColor(.black)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Report Action
                    Button(action: { 
                        UIApplication.shared.endEditing()
                        showingReport = true 
                    }) {
                        Image(systemName: "exclamationmark.bubble")
                            .foregroundColor(.gray)
                    }
                    
                    // Wallet Display
                    HStack(spacing: 4) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.caption)
                            .foregroundColor(NeonCouture.primary)
                        Text("\(coinManager.balance)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(NeonCouture.primary.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5))
            .sheet(isPresented: $showingReport) {
                ReportModalView(isPresented: $showingReport, showSuccess: $showReportSuccess)
            }
            
            // Messages List
            if #available(iOS 14.0, *) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(chatManager.messages) { message in
                                HStack {
                                    if message.isFromUser { Spacer() }
                                    
                                    Text(message.text)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            message.isFromUser ? 
                                            NeonCouture.primary : 
                                                Color.gray.opacity(0.1)
                                        )
                                        .foregroundColor(message.isFromUser ? .white : .black)
                                        .cornerRadius(20, corners: message.isFromUser ? [.topLeft, .bottomLeft, .bottomRight] : [.topRight, .bottomLeft, .bottomRight])
                                        .shadow(color: message.isFromUser ? NeonCouture.primary.opacity(0.3) : Color.clear, radius: 5)
                                    
                                    if !message.isFromUser { Spacer() }
                                }
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .onChange(of: chatManager.messages.count) { _ in
                        if let lastId = chatManager.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Premium Action Bar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Text("Support this Designer")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: sendGift) {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                            Text("SEND DIGITAL GIFT")
                                .font(.system(size: 10, weight: .bold))
                            HStack(spacing: 2) {
                                Image(systemName: "circle.hexagongrid.fill")
                                Text("10")
                            }
                            .font(.caption2.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(NeonCouture.primary)
                        .cornerRadius(20)
                        .neonGlow()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
            }
            
            // Input Field
            HStack(spacing: 12) {
                TextField("Ask about the collection...", text: $newMessageText)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(25)
                
                Button(action: {
                    if !newMessageText.isEmpty {
                        chatManager.sendMessage(newMessageText)
                        newMessageText = ""
                        UIApplication.shared.endEditing()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(NeonCouture.primary)
                                .neonGlow()
                        )
                }
                .disabled(newMessageText.isEmpty)
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 8)
            .background(Color.white)
        }
        .alert(isPresented: $showingLowBalanceAlert) {
            Alert(
                title: Text("Insufficient Coins"),
                message: Text("You need 10 coins to send a Designer Gift. Visit the boutique to top up!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarHidden(true)
        .background(NeonCouture.background.edgesIgnoringSafeArea(.all))
        .overlay(
            Group {
                if showReportSuccess {
                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(NeonCouture.primary)
                        Text("Report Received")
                            .font(.headline)
                            .padding(.top)
                        Text("We will review this designer shortly.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 20)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showReportSuccess = false
                        }
                    }
                }
            }
        )
    }
    
    func sendGift() {
        UIApplication.shared.endEditing()
        if coinManager.spendCoins(10) {
            let giftMsg = Message(text: "🎁 Sent a Digital Silk Gift to the designer!", isFromUser: true)
            chatManager.messages.append(giftMsg)
            
            // Designer Reaction
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                let reaction = Message(text: "Wow! Thank you for the gift. It really helps support our digital atelier. I'll prioritize your consultation!", isFromUser: false)
                chatManager.messages.append(reaction)
            }
        } else {
            showingLowBalanceAlert = true
        }
    }
}

struct ReportModalView: View {
    @Binding var isPresented: Bool
    @Binding var showSuccess: Bool
    
    let reasons = ["Spam", "Inappropriate Content", "Harassment", "Scam / Fake", "Other"]
    
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 12)
            
            Text("REPORT DESIGNER")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.black)
            
            VStack(spacing: 0) {
                ForEach(reasons, id: \.self) { reason in
                    Button(action: {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSuccess = true
                        }
                    }) {
                        HStack {
                            Text(reason)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    Divider()
                }
            }
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 10)
            
            Button("CANCEL") {
                isPresented = false
            }
            .font(.subheadline.bold())
            .foregroundColor(.gray)
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}


// Helper for specific corner rounding
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
