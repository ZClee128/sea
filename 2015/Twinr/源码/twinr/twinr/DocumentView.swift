import SwiftUI

@available(iOS 14.0, *)
struct DocumentView: View {
    let title: String
    let fileName: String
    @State private var content: String = "Loading..."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(content)
                    .font(.body)
                    .lineSpacing(6)
                    .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadContent()
        }
    }
    
    private func loadContent() {
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let loadedContent = try String(contentsOfFile: path, encoding: .utf8)
                self.content = loadedContent
            } catch {
                self.content = "Error loading document: \(error.localizedDescription)"
            }
        } else {
            self.content = "Document '\(fileName).txt' not found in bundle."
        }
    }
}
