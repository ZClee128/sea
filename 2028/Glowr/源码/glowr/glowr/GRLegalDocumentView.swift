import SwiftUI

struct GRLegalDocumentView: View {
    let fileName: String
    let title: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var content: String = "Loading..."
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        if #available(iOS 14.0, *) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.black.opacity(0.3))
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.black.opacity(0.1)),
                    alignment: .bottom
                )
                
                ScrollView {
                    Text(content)
                        .padding()
                        .foregroundColor(.black.opacity(0.8))
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .lineSpacing(6)
                }
            }
        }
        .onAppear(perform: loadContent)
    }
    
    func loadContent() {
        // Attempt to load from Bundle
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                content = try String(contentsOfFile: path, encoding: .utf8)
            } catch {
                content = "Error reading document contents."
            }
        } else {
            // Fallback for previews/mock if bundle path is not available
            content = "Document '\(fileName).txt' not found. Please ensure it is added to the app bundle."
        }
    }
}

struct GRLegalDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        GRLegalDocumentView(fileName: "PrivacyPolicy", title: "PRIVACY POLICY")
    }
}
