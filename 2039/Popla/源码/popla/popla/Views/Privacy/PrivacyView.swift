import SwiftUI

struct PrivacyView: View {
    @ObservedObject var privacyManager: PrivacyManager
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Spacer()
                
                // Icon / Logo Placeholder
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 12) {
                    Text("Popla")
                        .font(.custom("HelveticaNeue-Bold", size: 34))
                        .foregroundColor(.black)
                    
                    Text("Urban Life Rhythm".uppercased())
                        .font(.subheadline)
                        .tracking(2)
                        .foregroundColor(.gray)
                }
                
                Divider().padding(.horizontal, 40)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Before you start exploring the city, please review and agree to our Privacy Policy.")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(privacyManager.getPrivacyContent())
                            .font(.system(size: 13))
                            .lineSpacing(4)
                            .padding()
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .frame(maxHeight: 300)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        privacyManager.isAgreed = true
                    }
                }) {
                    Text("AGREE & START EXPLORING")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView(privacyManager: PrivacyManager())
    }
}
