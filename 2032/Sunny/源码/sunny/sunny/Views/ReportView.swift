import SwiftUI

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: String?
    @State private var reportText: String = ""
    @State private var isSubmitted = false
    
    let reasons = [
        "Harassment or Hate Speech",
        "Spam or Misleading",
        "Inappropriate Content",
        "Intellectual Property Violation",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !isSubmitted {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Why are you reporting this?")
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.top, 20)
                            
                            VStack(spacing: 0) {
                                ForEach(reasons, id: \.self) { reason in
                                    Button(action: { selectedReason = reason }) {
                                        HStack {
                                            Text(reason)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if selectedReason == reason {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                            } else {
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                        .background(Color.white)
                                    }
                                    if reason != reasons.last {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Additional Comments (Optional)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                
                                if #available(iOS 14.0, *) {
                                    TextEditor(text: $reportText)
                                        .frame(height: 120)
                                        .padding(8)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .padding(.horizontal, 16)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                            
                            Text("Your report is anonymous. We will review it and take appropriate action.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                        }
                    }
                    
                    Button(action: submitReport) {
                        Text("Submit Report")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedReason == nil ? Color.gray : Color(red: 1.0, green: 0.6, blue: 0.2))
                            .cornerRadius(12)
                    }
                    .disabled(selectedReason == nil)
                    .padding(16)
                    
                } else {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Report Submitted")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Thank you for helping us keep Sunny safe. Our team will review your report.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("Done")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                                .cornerRadius(24)
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .navigationBarTitle("Report", displayMode: .inline)

            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func submitReport() {
        withAnimation {
            isSubmitted = true
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
