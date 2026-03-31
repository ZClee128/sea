import SwiftUI

@available(iOS 15.0, *)
struct ReportView: View {
    let expertName: String
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: String?
    @State private var showConfirmation = false
    
    let reasons = [
        "Inappropriate Content",
        "Spam or Advertising",
        "Harassment",
        "Technical Misinformation",
        "Other"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Handle
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                // Header
                VStack(spacing: 8) {
                    Text("Report \(expertName)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Help us maintain the professional quality of Dazzl Study.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Reason List
                VStack(spacing: 12) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: { selectedReason = reason }) {
                            HStack {
                                Text(reason)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.red)
                                } else {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Submit Button
                Button(action: submitReport) {
                    Text(showConfirmation ? "Report Submitted" : "Submit Report")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedReason == nil ? Color.gray.opacity(0.3) : Color.red)
                        .cornerRadius(15)
                }
                .disabled(selectedReason == nil || showConfirmation)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func submitReport() {
        withAnimation {
            showConfirmation = true
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
