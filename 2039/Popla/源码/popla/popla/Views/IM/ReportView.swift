import SwiftUI

struct ReportReason: Identifiable {
    let id = UUID()
    let title: String
}

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: UUID?
    @State private var comment: String = ""
    @State private var isSubmitted = false
    
    let reasons = [
        ReportReason(title: "Spam or Advertising"),
        ReportReason(title: "Inappropriate Content"),
        ReportReason(title: "Harassment or Bullying"),
        ReportReason(title: "Privacy Violation"),
        ReportReason(title: "Fraud or Scam")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                if isSubmitted {
                    successView
                } else {
                    formView
                }
            }
            .navigationBarTitle(Text("Report Content"), displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onTapGesture {
                // Tap to dismiss keyboard in report view
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Select a reason")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.gray.opacity(0.4))
                
                VStack(spacing: 0) {
                    ForEach(reasons) { reason in
                        Button(action: { selectedReason = reason.id }) {
                            HStack {
                                Text(reason.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                                if selectedReason == reason.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.vertical, 20)
                            .contentShape(Rectangle())
                        }
                        
                        if reason.id != reasons.last?.id {
                            Divider()
                        }
                    }
                }
                
                Text("Additional comments")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.top, 10)
                
                TextField("Help us understand...", text: $comment)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                
                Button(action: {
                    withAnimation { isSubmitted = true }
                    // Auto-dismiss after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Submit Report")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(selectedReason == nil ? Color.gray.opacity(0.3) : Color.black)
                        .cornerRadius(35)
                }
                .disabled(selectedReason == nil)
                .padding(.top, 20)
                
                Text("Your report is anonymous. We will review this content within 24 hours.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(30)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 70))
                .foregroundColor(.black)
            
            Text("Thanks for Reporting")
                .font(.system(size: 24, weight: .black))
            
            Text("We've received your report and will take action if our community guidelines were violated.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
