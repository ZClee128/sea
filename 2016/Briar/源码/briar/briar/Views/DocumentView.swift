import SwiftUI

struct DocumentView: View {
    let filename: String
    let title: String
    
    @State private var documentText: String = "Loading..."
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            Text(documentText)
                .padding()
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(6)
        }
        .navigationBarTitle(Text(title), displayMode: .inline)
        .onAppear {
            if let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
               let text = try? String(contentsOf: url, encoding: .utf8) {
                self.documentText = text
            } else {
                // Fallback text if the bundle doesn't copy the txt file
                if filename == "Privacy" {
                    self.documentText = """
                    Briar Beauty Privacy Policy
                    
                    1. Information We Collect
                    We do not require user accounts or collect personally identifiable information (PII). All app settings, bookmarks, and viewing histories are stored strictly locally on your device via UserDefaults.
                    
                    2. Data Usage
                    Our app only stores minimal data locally to ensure proper functionality of favorites and histories.
                    
                    3. Contact
                    Please contact our privacy compliance team at doquangminh0404@icloud.com for more information.
                    """
                } else {
                    self.documentText = "Failed to load \(title). Please consult the bundle."
                }
            }
        }
    }
}
