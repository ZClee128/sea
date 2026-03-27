import SwiftUI
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Data Models
struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Auto Reply Bot
private let autoReplies = [
    "This artwork is absolutely breathtaking! ✨",
    "I love her expression in this piece 💫",
    "The color palette here is stunning! 🎨",
    "She looks so powerful and mysterious 🌙",
    "This is one of my favorites in the collection! ❤️",
    "The detail in the background is incredible 🌟",
    "Have you seen the other pieces in this category? 👀",
    "The artist really captured the essence perfectly 🔥",
    "I could stare at this all day long! 😍",
    "The lighting really brings her to life ✨"
]

// MARK: - IM Chat View
@available(iOS 15.0, *)
struct ArtChatView: View {
    let artItem: ArtItem

    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'd love to discuss this artwork with you 💬", isFromUser: false, timestamp: Date().addingTimeInterval(-120)),
        ChatMessage(text: "What do you think about this piece? ✨", isFromUser: false, timestamp: Date().addingTimeInterval(-60))
    ]
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var showReport = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            chatHeader

            Divider()

            // Messages list
            ScrollViewReader { proxy in
                if #available(iOS 16.0, *) {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                            if isTyping {
                                TypingIndicator()
                                    .id("typing_indicator")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .onChange(of: messages.count) { _ in
                        withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
                    }
                    .onChange(of: isTyping) { typing in
                        if typing { withAnimation { proxy.scrollTo("typing_indicator", anchor: .bottom) } }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }

            Divider()

            // Input Bar
            inputBar
        }
        .contentShape(Rectangle())
        .onTapGesture { UIApplication.shared.endEditing() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Muse Chat")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showReport = true }) {
                    Image(systemName: "exclamationmark.bubble")
                        .foregroundColor(.secondary)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showReport) {
            ReportView(artItem: artItem)
        }
    }

    // MARK: - Header
    private var chatHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.pink.opacity(0.7), .purple.opacity(0.8)]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                Image(systemName: "sparkles").foregroundColor(.white).font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Muse Chat").font(.headline).fontWeight(.semibold)
                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 7, height: 7)
                    Text("Online").font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(artItem.category)
                .font(.caption)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.pink.opacity(0.12))
                .foregroundColor(.pink).cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 10) {
            HStack {
                TextField("Message...", text: $inputText)
                    .focused($isInputFocused)
                    .font(.subheadline)
                    .submitLabel(.send)
                    .onSubmit { sendMessage() }
                if !inputText.isEmpty {
                    Button(action: { inputText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(22)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(inputText.isEmpty ? .gray : .pink)
            }
            .disabled(inputText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    // MARK: - Send Logic
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        withAnimation { messages.append(ChatMessage(text: text, isFromUser: true, timestamp: Date())) }
        inputText = ""
        isInputFocused = false

        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.0...2.5)) {
            isTyping = false
            let reply = autoReplies.randomElement() ?? "That's interesting! 😊"
            withAnimation { messages.append(ChatMessage(text: reply, isFromUser: false, timestamp: Date())) }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter(); f.timeStyle = .short; return f
    }()

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if message.isFromUser { Spacer(minLength: 50) }

            if !message.isFromUser {
                ZStack {
                    LinearGradient(colors: [.pink.opacity(0.6), .purple.opacity(0.7)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing).clipShape(Circle())
                    Image(systemName: "sparkles").foregroundColor(.white).font(.system(size: 12))
                }
                .frame(width: 30, height: 30)
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        message.isFromUser
                        ? AnyView(LinearGradient(colors: [.pink, .purple.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                        : AnyView(Color(.systemBackground))
                    )
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                if #available(iOS 14.0, *) {
                    Text(Self.timeFormatter.string(from: message.timestamp))
                        .font(.caption2).foregroundColor(.secondary).padding(.horizontal, 4)
                } else {
                    // Fallback on earlier versions
                }
            }

            if !message.isFromUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ZStack {
                LinearGradient(colors: [.pink.opacity(0.6), .purple.opacity(0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing).clipShape(Circle())
                Image(systemName: "sparkles").foregroundColor(.white).font(.system(size: 12))
            }
            .frame(width: 30, height: 30)

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color(.systemBackground)).cornerRadius(18)

            Spacer()
        }
        .onAppear { phase = 0 }
    }
}

// MARK: - Report View
@available(iOS 15.0, *)
struct ReportView: View {
    let artItem: ArtItem
    @Environment(\.dismiss) var dismiss

    let reasons = [
        ("Inappropriate Content", "flag.fill", Color.red),
        ("Spam or Scam", "exclamationmark.triangle.fill", Color.orange),
        ("Hate Speech", "hand.raised.fill", Color.purple),
        ("Harassment", "person.fill.xmark", Color.pink),
        ("Copyright Violation", "doc.fill", Color.blue),
        ("Other", "ellipsis.circle.fill", Color.gray)
    ]
    @State private var selectedReason: String? = nil
    @State private var additionalInfo = ""
    @State private var submitted = false
    @FocusState private var isTextFocused: Bool

    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header info
                        HStack(spacing: 14) {
                            ZStack {
                                LinearGradient(colors: [.pink.opacity(0.6), .purple.opacity(0.8)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                Image(systemName: "flag.fill").foregroundColor(.white).font(.system(size: 22))
                            }
                            .frame(width: 52, height: 52)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Report Content").font(.headline).fontWeight(.bold)
                                Text("\(artItem.title)")
                                    .font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        
                        // Reason selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What's the issue?")
                                .font(.headline).fontWeight(.semibold)
                            
                            ForEach(reasons, id: \.0) { reason, icon, color in
                                Button(action: { selectedReason = reason }) {
                                    HStack(spacing: 14) {
                                        Image(systemName: icon)
                                            .foregroundColor(color)
                                            .font(.system(size: 18))
                                            .frame(width: 28)
                                        
                                        Text(reason)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedReason == reason ? .pink : .secondary)
                                            .font(.system(size: 20))
                                    }
                                    .padding()
                                    .background(
                                        selectedReason == reason
                                        ? Color.pink.opacity(0.08)
                                        : Color(.systemBackground)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedReason == reason ? Color.pink.opacity(0.4) : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Additional info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Details (optional)")
                                .font(.headline).fontWeight(.semibold)
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .frame(minHeight: 100)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                                TextEditor(text: $additionalInfo)
                                    .focused($isTextFocused)
                                    .font(.subheadline)
                                    .padding(10)
                                    .frame(minHeight: 100)
                                if additionalInfo.isEmpty {
                                    Text("Describe the issue in more detail...")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                        .padding(16)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        
                        // Submit
                        Button(action: submitReport) {
                            HStack {
                                Spacer()
                                if submitted {
                                    Label("Report Submitted", systemImage: "checkmark.circle.fill")
                                        .font(.headline).foregroundColor(.white)
                                } else {
                                    Text("Submit Report")
                                        .font(.headline).foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(selectedReason == nil ? Color.gray : (submitted ? Color.green : Color.pink))
                            .cornerRadius(14)
                        }
                        .disabled(selectedReason == nil || submitted)
                        .animation(.easeInOut, value: submitted)
                    }
                    .padding()
                }
                .contentShape(Rectangle())
                .onTapGesture { UIApplication.shared.endEditing() }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Report")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    private func submitReport() {
        isTextFocused = false
        withAnimation { submitted = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
    }
}
