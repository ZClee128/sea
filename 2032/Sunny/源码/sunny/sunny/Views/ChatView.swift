import SwiftUI

@available(iOS 14.0, *)
struct ChatView: View {
    let designer: Designer
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var showReport = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            HStack(spacing: 12) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                if let avatar = UIImage(named: designer.avatarName) {
                    Image(uiImage: avatar)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(designer.name)
                        .font(.system(size: 16, weight: .bold))
                    Text("Designer • Online")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button(action: { showReport = true }) {
                    Image(systemName: "exclamationmark.bubble")
                        .foregroundColor(.red.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }

                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            
            // 输入栏
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)

                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(20)
                
                if !messageText.isEmpty {
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showReport) {
            ReportView()
        }
        .onAppear {
            setupInitialMessages()
        }
    }
    
    func setupInitialMessages() {
        messages = [
            ChatMessage(text: "Hi there! I'm \(designer.name). How can I help you today?", timestamp: Date().addingTimeInterval(-3600), isFromUser: false)
        ]
    }
    
    private let randomReplies = [
        "That's a great question! I'd love to share more details about the design process.",
        "I'm so glad you like it! It's one of my favorite pieces from this collection.",
        "We used premium sustainable materials for this one. It's as comfortable as it is stylish.",
        "I'm currently working on some new color variants for this - stay tuned!",
        "Feel free to ask anything else about the styling or fit!",
        "I can certainly help with that. Are you looking for a specific size?",
        "That's a very observant question. The inspiration came from vintage European street style."
    ]
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = ChatMessage(text: messageText, timestamp: Date(), isFromUser: true)
        messages.append(newMessage)
        messageText = ""
        
        // 模拟随机回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let replyText = randomReplies.randomElement() ?? "I'll get back to you on that very soon!"
            let reply = ChatMessage(text: replyText, timestamp: Date(), isFromUser: false)
            withAnimation {
                messages.append(reply)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            Text(message.text)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromUser ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color.white)
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            
            if !message.isFromUser { Spacer() }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            ChatView(designer: FashionData.designers[0])
        } else {
            // Fallback on earlier versions
        }
    }
}
