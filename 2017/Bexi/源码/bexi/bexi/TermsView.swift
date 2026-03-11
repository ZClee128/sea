import SwiftUI

struct TermsView: View {
    @EnvironmentObject var storageManager: StorageManager
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            VStack(spacing: 8) {
                Text("Welcome to Bexi")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                Text("Before you dive into the world of cosplay and fashion, please review our terms.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 20)
            
            // Realistic Terms ScrollView
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service & Privacy Policy")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text("1. Acceptance of Terms")
                        .font(.subheadline).bold()
                    Text("By accessing and using Bexi, you accept and agree to be bound by the terms and provisions of this agreement.")
                        .font(.footnote).foregroundColor(.secondary)
                    
                    Text("2. User Generated Content")
                        .font(.subheadline).bold()
                    Text("Bexi displays content from various creators. You agree not to distribute, modify, or misuse the visual content beyond personal inspiration and moodboard creation. We reserve the right to remove any content that violates intellectual property rights.")
                        .font(.footnote).foregroundColor(.secondary)
                    
                    Text("3. Privacy & Data Collection")
                        .font(.subheadline).bold()
                    Text("We respect your privacy. Bexi operates primarily on your local device. Your saved collections and moodboards are stored locally and are not uploaded to our servers unless explicitly shared by you.")
                        .font(.footnote).foregroundColor(.secondary)
                    
                    Text("4. Appropriate Usage")
                        .font(.subheadline).bold()
                    Text("You agree to use Bexi strictly for lawful purposes. Any attempt to reverse engineer the app or scrape its visual data systematically is strictly prohibited.")
                        .font(.footnote).foregroundColor(.secondary)
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .frame(maxHeight: 400)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        self.storageManager.acceptTerms()
                    }
                }) {
                    Text("Accept & Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    // For a real app, declining usually exits or shows an alert. 
                    // We'll leave it as a visual button that doesn't proceed.
                }) {
                    Text("Decline")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .padding(.top, 20)
        }
    }
}

#Preview {
    TermsView()
        .environmentObject(StorageManager())
}
