import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
    let timestamp: Date
}

struct ChatView: View {
    let authorName: String
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var showingCustomReport = false
    @State private var showingReportResult = false
    
    init(authorName: String) {
        self.authorName = authorName
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
    
    func generateReply(for input: String) -> String {
        let lowerInput = input.lowercased()
        
        if lowerInput.contains("hi") || lowerInput.contains("hello") || lowerInput.contains("hey") {
            return ["Hello there! So nice to meet you 😊", "Hi! Thanks for checking out my profile.", "Hey! How can I help you today?"].randomElement()!
        }
        if lowerInput.contains("skin") || lowerInput.contains("face") || lowerInput.contains("wash") || lowerInput.contains("acne") {
            return ["I highly recommend double cleansing if you wear makeup!", "Always remember to apply sunscreen as the very last step in your morning routine.", "Hyaluronic acid is a game changer for keeping your skin plump.", "Don't forget to moisturize even if your skin is oily!"].randomElement()!
        }
        if lowerInput.contains("lip") || lowerInput.contains("eye") || lowerInput.contains("makeup") || lowerInput.contains("color") {
            return ["For a bolder look, try applying a darker shade on the outer corners.", "A good setting spray will make your makeup last all day.", "Lip oils are my current obsession right now!", "Always prep your eyelids with a primer before putting on eyeshadow."].randomElement()!
        }
        if lowerInput.contains("?") || lowerInput.contains("how") || lowerInput.contains("what") {
            return ["That's a fantastic question! It really depends on your personal style, but I'd say give it a try.", "In my experience, yes! But always do a skin patch test first.", "Usually I'd recommend matching it to your undertone. Experimenting is key!"].randomElement()!
        }
        
        let general = [
            "Thank you so much! I love sharing these tips.",
            "That's so true! Beauty is all about experimenting.",
            "I completely agree.",
            "You should totally try the routine I posted yesterday.",
            "I've been using this exact method for years.",
            "Make sure to blend it out completely for a seamless look.",
            "It really depends on your skin type, but generally yes.",
            "Let me know if you want a detailed video tutorial on that!"
        ]
        return general.randomElement()!
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                .onTapGesture {
                    hideKeyboard()
                }
                
                Divider()
                
                HStack {
                    TextField("Message \(authorName)...", text: $inputText)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .navigationBarTitle(Text(authorName), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                hideKeyboard()
                withAnimation { showingCustomReport = true }
            }) {
                Image(systemName: "exclamationmark.bubble")
                    .foregroundColor(.red)
            })
            .onAppear {
                if messages.isEmpty {
                    messages.append(ChatMessage(text: "Hi there! I'm \(authorName). Let me know if you have any questions about my posts or makeup tips!", isCurrentUser: false, timestamp: Date()))
                }
            }
            
            // Custom Modals
            if showingCustomReport || showingReportResult {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showingCustomReport = false
                            showingReportResult = false
                        }
                    }
                    // Place above navigation bar if possible via ZStack layering
                    .zIndex(1)
                
                if showingCustomReport {
                    customReportMenu
                        .transition(.move(edge: .bottom))
                        .zIndex(2)
                }
                
                if showingReportResult {
                    customReportResult
                        .transition(.scale)
                        .zIndex(2)
                }
            }
        }
    }
    
    var customReportMenu: some View {
        VStack(spacing: 0) {
            Text("Report \(authorName)")
                .font(.headline)
                .padding()
            
            Divider()
            
            VStack(spacing: 0) {
                ReportButton(title: "Spam or Advertising", color: .red) { submitReport() }
                ReportButton(title: "Inappropriate Content", color: .red) { submitReport() }
                ReportButton(title: "Harassment or Bullying", color: .red) { submitReport() }
            }
            
            Rectangle()
                .fill(Color(UIColor.systemGray6))
                .frame(height: 8)
            
            Button(action: {
                withAnimation { showingCustomReport = false }
            }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 40)
        .shadow(color: Color.black.opacity(0.2), radius: 20)
    }
    
    var customReportResult: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Report Submitted")
                .font(.system(size: 22, weight: .bold))
            
            Text("Thank you for your report. Our moderation team will strictly review this account's behavior within 24 hours to ensure a safe environment.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                withAnimation { showingReportResult = false }
            }) {
                Text("Under Review")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 30)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 30)
        .shadow(color: Color.black.opacity(0.3), radius: 30)
    }
    
    func submitReport() {
        withAnimation {
            showingCustomReport = false
            showingReportResult = true
        }
    }
    
    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        
        let newMsg = ChatMessage(text: text, isCurrentUser: true, timestamp: Date())
        messages.append(newMsg)
        inputText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let replyText = generateReply(for: text)
            let reply = ChatMessage(text: replyText, isCurrentUser: false, timestamp: Date())
            messages.append(reply)
        }
    }
}

struct ReportButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding()
        }
        Divider()
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser { Spacer() }
            
            Text(message.text)
                .padding(12)
                .background(message.isCurrentUser ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(message.isCurrentUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 260, alignment: message.isCurrentUser ? .trailing : .leading)
            
            if !message.isCurrentUser { Spacer() }
        }
    }
}
