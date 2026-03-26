import SwiftUI

struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

@available(iOS 15.0, *)
struct ChatView: View {
    let chefName: String
    @State private var messages: [Message] = []
    @State private var newMessageText: String = ""
    @FocusState private var isFocused: Bool
    @State private var showingReport = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onTapGesture {
                    isFocused = false
                }
                .onChange(of: messages) { _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            Divider()
            HStack(spacing: 12) {
                TextField("Ask the chef...", text: $newMessageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .focused($isFocused)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(newMessageText.isEmpty ? .secondary : .accentColor)
                }
                .disabled(newMessageText.isEmpty)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("Chat with \(chefName)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showingReport = true
        }) {
            Image(systemName: "exclamationmark.bubble")
                .foregroundColor(.red)
        })
        .sheet(isPresented: $showingReport) {
            if #available(iOS 15.0, *) {
                ReportView(chefName: chefName)
            } else {
                Text("Reporting is only available on iOS 15.0 or newer.")
            }
        }
        .onAppear {
            if messages.isEmpty {
                messages.append(Message(text: "Hi there! I'm Chef \(chefName). Any questions about the recipe?", isFromUser: false))
            }
        }
    }
    
    private func sendMessage() {
        let text = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add User Message
        let userMsg = Message(text: text, isFromUser: true)
        messages.append(userMsg)
        newMessageText = ""
        isFocused = false // Dismiss keyboard
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Mock Chef Reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let reply = getChefReply(to: text)
            let chefMsg = Message(text: reply, isFromUser: false)
            withAnimation {
                messages.append(chefMsg)
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func getChefReply(to text: String) -> String {
        let input = text.lowercased()
        if input.contains("hello") || input.contains("hi") {
            return "Hello! Ready to cook something amazing today?"
        } else if input.contains("substitute") || input.contains("instead") {
            return "Good question! You can usually substitute fresh herbs with dried ones, just use 1/3 the amount."
        } else if input.contains("salt") {
            return "I always recommend seasoning to taste. Start small and add more as you go!"
        } else if input.contains("hard") || input.contains("difficult") {
            return "Don't worry! Just follow the steps one by one. You've got this!"
        } else {
            return "That's a great observation! Cooking is all about experimentation. Let me know if you need specific steps clarified."
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isFromUser ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(18)
                .frame(maxWidth: 280, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser { Spacer() }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                ChatView(chefName: "Gordon")
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
