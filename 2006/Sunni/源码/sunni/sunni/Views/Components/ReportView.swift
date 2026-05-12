//
//  ReportView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 15.0, *)
struct ReportView: View {
    let reportType: ReportType
    let targetId: UUID
    
    @State private var selectedReason: ReportReason = .spam
    @State private var details: String = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) var dismiss
    
    private let blockService = BlockService.shared
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section("Reason") {
                    Picker("Select a reason", selection: $selectedReason) {
                        ForEach(ReportReason.allCases, id: \.self) { reason in
                            Text(reason.rawValue).tag(reason)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Additional Details (Optional)") {
                    TextEditor(text: $details)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: submitReport) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit Report")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color(hex: "E74C3C"))
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle(reportType == .post ? "Report Post" : "Report User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitReport() {
        guard let userId = authService.authState.currentUser?.id else { return }
        
        isSubmitting = true
        
        let report = Report(
            type: reportType,
            targetId: targetId,
            reporterId: userId,
            reason: selectedReason,
            details: details.isEmpty ? nil : details
        )
        
        blockService.submitReport(report)
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            dismiss()
        }
    }
}

@available(iOS 15.0, *)
struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(reportType: .post, targetId: UUID())
    }
}
