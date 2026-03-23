import SwiftUI

struct HistoryView: View {
    @State private var historyPosts: [Post] = []
    
    var body: some View {
        Group {
            if historyPosts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No history yet.")
                        .font(.headline)
                }
            } else {
                List {
                    ForEach(historyPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text("Recently viewed")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitle("Reading History")
        .onAppear(perform: loadHistory)
    }
    
    func loadHistory() {
        let historyIDs = UserDefaults.standard.stringArray(forKey: "HistoryPosts") ?? []
        // Map over historyIDs to preserve chronological order (most recent first)
        historyPosts = historyIDs.compactMap { id in
            mockPosts.first(where: { $0.id == id })
        }
    }
}
