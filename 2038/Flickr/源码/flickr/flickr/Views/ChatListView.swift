import SwiftUI

@available(iOS 15.0, *)
struct ChatListView: View {
    @StateObject var chatManager = ChatManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chatManager.activeSessions.filter { !$0.isBlocked }) { session in
                    NavigationLink(destination: ChatDetailView(sessionId: session.id)) {
                        HStack(spacing: 16) {
                            Image(session.partner.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.partner.title)
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                                    .foregroundColor(.black)
                                
                                Text(session.lastMessage)
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Connect")
            .listStyle(PlainListStyle())
        }
    }
}

@available(iOS 15.0, *)
struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
