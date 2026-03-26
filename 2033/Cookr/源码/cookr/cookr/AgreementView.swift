import SwiftUI

struct AgreementView: View {
    let isReadOnly: Bool
    let fileName: String
    let onAgree: () -> Void
    @State private var agreementText: String = "Loading..."
    
    init(isReadOnly: Bool = false, fileName: String = "Agreement", onAgree: @escaping () -> Void = {}) {
        self.isReadOnly = isReadOnly
        self.fileName = fileName
        self.onAgree = onAgree
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if !isReadOnly {
                Image(systemName: "hand.raised.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)
                    .padding(.top, 40)
            }
            
            Text(isReadOnly ? (fileName == "Agreement" ? "Terms of Service" : "Privacy Policy") : "User Agreement")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, isReadOnly ? 20 : 0)
            
            ScrollView {
                Text(agreementText)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            if !isReadOnly {
                Button(action: onAgree) {
                    Text("Agree & Continue")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            } else {
                Spacer().frame(height: 20)
            }
        }
        .onAppear(perform: loadContent)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    private func loadContent() {
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                agreementText = try String(contentsOfFile: path)
            } catch {
                agreementText = "Failed to load content. Please restart the app."
            }
        } else {
            agreementText = "Content file '\(fileName).txt' not found."
        }
    }
}

struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView(onAgree: {})
    }
}
