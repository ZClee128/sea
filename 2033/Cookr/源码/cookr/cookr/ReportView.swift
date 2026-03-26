import SwiftUI
import Combine

@available(iOS 15.0, *)
struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
    let chefName: String
    
    @State private var selectedReason: String?
    @State private var reportText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    let reasons = [
        "Spam / Advertising",
        "Harassment / Bullying",
        "Inappropriate Content",
        "Offensive Language",
        "Scam / Fraud",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Why are you reporting Chef \(chefName)?")) {
                    ForEach(reasons, id: \.self) { reason in
                        HStack {
                            Text(reason)
                            Spacer()
                            if selectedReason == reason {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReason = reason
                            isFieldFocused = false
                        }
                    }
                }
                
                Section(header: Text("Additional Details (Optional)")) {
                    TextEditor(text: $reportText)
                        .frame(minHeight: 100)
                        .focused($isFieldFocused)
                }
            }
            .navigationTitle("Report Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFieldFocused = false
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Submit") {
                    submitReport()
                }
                .disabled(selectedReason == nil || isSubmitting)
            )
            .overlay(
                Group {
                    if isSubmitting {
                        ZStack {
                            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                            ProgressView("Submitting...")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
            )
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Report Submitted"),
                    message: Text("Thank you for your report. Our moderation team will review it shortly."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    private func submitReport() {
        isSubmitting = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Mock API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ReportView(chefName: "Giovanni")
        } else {
            // Fallback on earlier versions
        }
    }
}
