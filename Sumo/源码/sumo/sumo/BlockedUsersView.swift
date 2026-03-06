import SwiftUI

struct BlockedUsersView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        Group {
            if appState.blockedUsernames.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No blocked users")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(Array(appState.blockedUsernames), id: \.self) { username in
                        HStack {
                            Text(username)
                            Spacer()
                            Button("Unblock") {
                                withAnimation {
                                    appState.unblockUser(username)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
    }
}
