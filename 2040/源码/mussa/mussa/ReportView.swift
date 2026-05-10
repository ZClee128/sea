import SwiftUI

struct ReportView: View {
    let targetName: String
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: String?
    @State private var additionalDetails: String = ""
    @State private var isSubmitted = false
    
    let reasons = [
        "Inappropriate Content",
        "Spam or Scam",
        "Harassment or Bullying",
        "Intellectual Property Violation",
        "False Information",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                    .onTapGesture { hideKeyboard() }
                
                if isSubmitted {
                    successView
                } else {
                    formView
                }
            }
            .navigationBarTitle("Report \(targetName)", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why are you reporting this?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(reasons, id: \.self) { reason in
                            Button(action: { 
                                hideKeyboard()
                                selectedReason = reason 
                            }) {
                                HStack {
                                    Text(reason)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedReason == reason {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            .frame(width: 22, height: 22)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                            }
                            if reason != reasons.last {
                                Divider().padding(.leading)
                            }
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Details (Optional)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if #available(iOS 14.0, *) {
                        TextEditor(text: $additionalDetails)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                Button(action: submitReport) {
                    Text("Submit Report")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedReason == nil ? Color.gray : Color.red)
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                .disabled(selectedReason == nil)
                
                Text("Your report is anonymous. We will review it within 24 hours.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                
                Spacer(minLength: 50)
            }
            .padding(.top)
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
        }
    }
    
    var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            if #available(iOS 14.0, *) {
                Text("Report Received")
                    .font(.title2.bold())
            } else {
                // Fallback on earlier versions
            }
            
            Text("Thank you for helping us keep Mussa safe. Our moderation team will investigate this content immediately.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.top, 20)
        }
    }
    
    private func submitReport() {
        hideKeyboard()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            isSubmitted = true
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
