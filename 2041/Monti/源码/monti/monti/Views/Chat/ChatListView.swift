import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var stageData: StageDataRepository
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Chats header description
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Coordinators Inbox")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Discuss choreography sequences and training paces")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Conversations List
                        if stageData.conversations.isEmpty {
                            Text("No chats active.")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.top, 40)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(stageData.conversations) { convo in
                                    NavigationLink(destination: ChatDetailView(convoId: convo.id)) {
                                        ChatRowView(convo: convo)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Custom Divider (iOS 13 safe)
                                    Divider()
                                        .background(Color.white.opacity(0.08))
                                        .padding(.leading, 72)
                                }
                            }
                            .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Monti Chats"), displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ChatRowView: View {
    let convo: ChatConversation
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Text(convo.partnerAvatar)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
            
            // Text Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(convo.partnerName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let lastMsg = convo.messages.last {
                        Text(formatTime(lastMsg.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    if let lastMsg = convo.messages.last {
                        Text(lastMsg.content)
                            .font(.system(size: 13))
                            .foregroundColor(convo.unreadCount > 0 ? .white : .gray)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Unread Count Bubble
                    if convo.unreadCount > 0 {
                        Text("\(convo.unreadCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(red: 1.00, green: 0.00, blue: 0.50))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .contentShape(Rectangle()) // Ensures entire row remains clickable
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
            .environmentObject(StageDataRepository())
    }
}
