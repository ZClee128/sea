//
//  SettingsView.swift
//  tego
//

import SwiftUI

struct SettingsView: View {
    @State private var cacheSize = "14.2 MB"
    @State private var showingClearAlert = false
    @State private var showingCoinStore = false
    
    var coinBalance: Int {
        UserDefaults.standard.integer(forKey: "user_coins")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coins")) {
                    Button(action: {
                        showingCoinStore = true
                    }) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("My Coins")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(coinBalance) coins")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("App Utilities")) {
                    Button(action: {
                        showingClearAlert = true
                    }) {
                        HStack {
                            Text("Clear Local Cache")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(cacheSize)
                                .foregroundColor(.secondary)
                        }
                    }
                    .alert(isPresented: $showingClearAlert) {
                        Alert(
                            title: Text("Clear Cache"),
                            message: Text("Are you sure you want to clear temporary data? This will free up space."),
                            primaryButton: .destructive(Text("Clear")) {
                                cacheSize = "0.0 MB"
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section(header: Text("Legal Information")) {
                    NavigationLink(destination: LegalTextView(type: .terms)) {
                        Text("Terms of Use")
                    }
                    
                    NavigationLink(destination: LegalTextView(type: .privacy)) {
                        Text("Privacy Policy")
                    }
                }
                
                Section(header: Text("About"), footer: Text("Tego v1.0.0")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarTitle(Text("Settings"))
            // Sheet must be on NavigationView, NOT on Section — sections get rebuilt by Form internals
            .sheet(isPresented: $showingCoinStore) {
                CoinStoreView()
            }
        }
    }
}
