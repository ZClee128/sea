import SwiftUI

@available(iOS 15.0, *)
struct AgreementView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "shield.righthalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.primary)
            
            Text("Welcome to Sumo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("To provide you with the best Lookbook experience, we need you to agree to our Terms of Use and Privacy Policy.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.blue)
                        Text("Explore thousands of curated streetwear and vintage outfits.")
                            .font(.subheadline)
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "play.rectangle")
                            .foregroundColor(.blue)
                        Text("Watch high-quality video lookbooks from creators.")
                            .font(.subheadline)
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "archivebox")
                            .foregroundColor(.blue)
                        Text("Save your favorites locally to your personal Wardrobe.")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        appState.hasAgreedToTerms = true
                    }
                }) {
                    Text("Agree & Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary)
                        .cornerRadius(12)
                }
                
                HStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("and")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(".")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .padding(30)
    }
}

@available(iOS 15.0, *)
struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView().environmentObject(AppStateManager())
    }
}
