//
//  ReportView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct ReportView: View {
    let targetUsername: String // 新增：接收目标用户名
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: String? = nil
    @State private var detailText = ""
    @State private var showSuccess = false
    
    let reasons = [
        "Spam or Advertisement",
        "Harassment or Bullying",
        "Hate Speech",
        "Inappropriate Content",
        "Intellectual Property Violation",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.all)
                
                if showSuccess {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.accent)
                        Text("Report Submitted")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Thank you for keeping Vibble safe. Our team will review this content within 24 hours.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .transition(.scale)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            Text("Why are you reporting this?")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.top)
                            
                            // 原因列表
                            VStack(spacing: 1) {
                                ForEach(reasons, id: \.self) { reason in
                                    Button(action: { selectedReason = reason }) {
                                        HStack {
                                            Text(reason).foregroundColor(.white)
                                            Spacer()
                                            if selectedReason == reason {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Theme.primary)
                                            } else {
                                                Circle().stroke(Color.gray, lineWidth: 1).frame(width: 20, height: 20)
                                            }
                                        }
                                        .padding()
                                        .background(Theme.cardBackground)
                                    }
                                }
                            }
                            .cornerRadius(15)
                            
                            // 详细说明
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Additional Details (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextEditor(text: $detailText)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Theme.cardBackground)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                            
                            // 提交按钮
                            VStack(spacing: 15) {
                                Toggle(isOn: Binding(
                                    get: { FriendManager.shared.isBlocked(targetUsername) },
                                    set: { _ in FriendManager.shared.toggleBlock(targetUsername) }
                                )) {
                                    Text("Block this user")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Theme.cardBackground)
                                .cornerRadius(10)
                                
                                Button(action: {
                                    withAnimation { showSuccess = true }
                                }) {
                                    Text("Submit Report")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(selectedReason == nil ? Color.gray : Theme.primary)
                                        .cornerRadius(15)
                                }
                                .disabled(selectedReason == nil)
                            }
                            
                            Text("Vibble's moderation team will investigate your report and take appropriate action.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 20)
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle()) // 关键：定义点击区域
                        .onTapGesture { UIApplication.shared.endEditing() } // 关键：内部触发
                    }
                }
            }
            .navigationTitle("Report Content")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.white))
        }
    }
}
