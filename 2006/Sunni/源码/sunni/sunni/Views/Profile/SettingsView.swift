//
//  SettingsView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct SettingsView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Account actions
                Section {
                    Button(action: { showLogoutConfirm = true }) {
                        HStack {
                            Label("退出登录", systemImage: "arrow.right.square")
                            Spacer()
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        Label("注销账号", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("退出登录", isPresented: $showLogoutConfirm) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) {
                    authService.logout()
                    dismiss()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
            .alert("注销账号", isPresented: $showDeleteConfirm) {
                Button("取消", role: .cancel) {}
                Button("注销", role: .destructive) {
                    authService.deleteAccount()
                    dismiss()
                }
            } message: {
                Text("此操作不可撤销，所有数据将被永久删除。")
            }
        }
    }
}

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
