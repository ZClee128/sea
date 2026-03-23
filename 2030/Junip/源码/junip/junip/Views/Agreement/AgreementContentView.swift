import SwiftUI

@available(iOS 14.0, *)
struct AgreementContentView: View {
    let title: String
    let fileName: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var content: String = "Loading..."
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(AppTheme.bodyRegular(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: loadContent)
        }
    }
    
    private func loadContent() {
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                content = try String(contentsOfFile: path, encoding: .utf8)
            } catch {
                content = "Error loading content."
            }
        } else {
            content = "File not found: \(fileName).txt"
        }
    }
}
