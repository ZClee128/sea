import SwiftUI
import Combine

struct ChatDetailView: View {
    @EnvironmentObject var stageData: StageDataRepository
    @Environment(\.presentationMode) var presentationMode
    let convoId: UUID
    
    @State private var typedText: String = ""
    
    @State private var showingReportIMSheet = false
    @State private var showingReportSuccessAlert = false
    
    var conversation: ChatConversation? {
        stageData.conversations.first(where: { $0.id == convoId })
    }
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            VStack {
                if let convo = conversation {
                    // Chat header info (stunt coach context)
                    HStack(spacing: 12) {
                        Text(convo.partnerAvatar)
                            .font(.system(size: 20))
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(convo.partnerName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text(convo.partnerRole)
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                    
                    // Messages scrollable area (iOS 13 safe)
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(convo.messages) { msg in
                                MessageBubbleView(message: msg)
                            }
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                    
                    // Bottom Input Field
                    HStack(spacing: 12) {
                        TextField("Type rehearsal coordination...", text: $typedText)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            sendMessage()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color(red: 1.00, green: 0.00, blue: 0.50))
                                .clipShape(Circle())
                        }
                        .disabled(typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .padding(.top, 8)
                    
                } else {
                    Text("Conversation not found")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationBarTitle(Text(conversation?.partnerName ?? "Chat"), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                showingReportIMSheet = true
            }) {
                Image(systemName: "flag")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        )
        .sheet(isPresented: $showingReportIMSheet) {
            if let convo = conversation {
                ReportView(
                    targetType: .im,
                    targetName: convo.partnerName,
                    targetContent: convo.messages.last?.content ?? "No messages in this chat.",
                    onSubmit: { reason in
                        showingReportIMSheet = false
                        stageData.reportConversation(id: convoId)
                        showingReportSuccessAlert = true
                    },
                    onCancel: {
                        showingReportIMSheet = false
                    }
                )
            }
        }
        .alert(isPresented: $showingReportSuccessAlert) {
            Alert(
                title: Text("Report Submitted"),
                message: Text("User reported successfully. It has been submitted for moderation review."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            markAsRead()
        }
    }
    
    private func sendMessage() {
        let trimmed = typedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        stageData.sendMessage(to: convoId, text: trimmed)
        typedText = ""
        
        // Ensure UI updates and sets conversation read
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.markAsRead()
        }
    }
    
    private func markAsRead() {
        if let idx = stageData.conversations.firstIndex(where: { $0.id == convoId }) {
            stageData.conversations[idx].unreadCount = 0
            stageData.objectWillChange.send()
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.00, green: 0.00, blue: 0.50), Color(red: 0.50, green: 0.00, blue: 1.00)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .cornerRadius(4, corners: .topRight) // custom rounded corner is a bit tricky, standard is fine
                    
                    Text(formatTime(message.timestamp))
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .padding(.trailing, 4)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.20))
                        .cornerRadius(16)
                        .cornerRadius(4, corners: .topLeft)
                    
                    Text(formatTime(message.timestamp))
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Helper to support iOS 13 custom rounded corners or fall back
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let repo = StageDataRepository()
        return ChatDetailView(convoId: repo.conversations[0].id)
            .environmentObject(repo)
    }
}
