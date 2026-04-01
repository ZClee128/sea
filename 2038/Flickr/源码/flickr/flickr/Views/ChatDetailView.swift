import SwiftUI


@available(iOS 15.0, *)
struct ChatDetailView: View {
    @ObservedObject var chatManager = ChatManager.shared
    let sessionId: UUID
    @State private var inputText: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showingReport = false
    @State private var showingBlock = false
    @FocusState private var isInputActive: Bool
    
    var session: ChatSession? {
        chatManager.activeSessions.first(where: { $0.id == sessionId })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let session = session {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(session.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isInputActive = false
                        }
                    }
                    .onChange(of: session.messages.count) { _ in
                        if let lastMessageId = session.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input Area or Blocked Notice
                if session.isBlocked {
                    HStack {
                        Spacer()
                        Text("You have blocked this guide.")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                } else {
                    HStack(spacing: 12) {
                        TextField("Share your thoughts...", text: $inputText)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                            .font(.system(size: 16, design: .serif))
                            .focused($isInputActive)
                            .submitLabel(.send)
                            .onSubmit(sendMessage)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                }
            } else {
                Text("Chat not found")
            }
        }
        .navigationTitle(session?.partner.title ?? "Connect")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) { showingReport = true } label: {
                        Label("Report", systemImage: "flag")
                    }
                    Button(role: .destructive) { showingBlock = true } label: {
                        Label("Block", systemImage: "hand.raised")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
//            ToolbarItemGroup(placement: .keyboard) {
//                Spacer()
//                Button("Done") {
//                    isInputActive = false
//                }
//                .font(.system(size: 16, weight: .bold, design: .serif))
//                .foregroundColor(.black)
//            }
        }
        .alert("Report Content", isPresented: $showingReport) {
            Button("Cancel", role: .cancel) { }
            Button("Submit", role: .destructive) { chatManager.reportSession(sessionId) }
        } message: {
            Text("Are you sure you want to report this conversation for investigation?")
        }
        .alert("Block Guide", isPresented: $showingBlock) {
            Button("Cancel", role: .cancel) { }
            Button("Block", role: .destructive) { 
                chatManager.blockSession(sessionId)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You will no longer receive messages from this aesthetic guide.")
        }
        .onTapGesture {
            isInputActive = false
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            chatManager.sendMessage(text, to: sessionId)
            inputText = ""
            triggerHaptic()
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

@available(iOS 15.0, *)
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .me { Spacer() }
            
            Text(message.text)
                .font(.system(size: 16, design: .serif))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.sender == .me ? Color.black : Color.gray.opacity(0.1))
                .foregroundColor(message.sender == .me ? .white : .black)
                .cornerRadius(18)
                .frame(maxWidth: 280, alignment: message.sender == .me ? .trailing : .leading)
            
            if message.sender == .partner { Spacer() }
        }
    }
}
