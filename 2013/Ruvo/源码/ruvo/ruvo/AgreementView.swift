import SwiftUI

struct AgreementView: View {
    @ObservedObject var agreementManager = AgreementManager.shared
    var isReadOnly: Bool = false
    
    var body: some View {
        Group {
            if isReadOnly {
                mainContent
            } else {
                NavigationView {
                    mainContent
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    var mainContent: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Group {
                        Text("End User License Agreement (EULA)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .padding(.top, 10)
                        
                        Text("1. Acceptance of Terms")
                            .fontWeight(.bold)
                        Text("By downloading or using the Ruvo application ('App'), you agree to be bound by these terms. If you do not agree, do not use the App.")
                        
                        Text("2. Intellectual Property")
                            .fontWeight(.bold)
                        Text("All reference artworks, UI designs, and functionality within the App are the property of Ruvo or its content providers. The App is provided for personal, non-commercial use as an artistic reference tool. Users may not extract, reverse-engineer, or redistribute any internal assets without explicit permission.")
                        
                        Text("3. No Warranty")
                            .fontWeight(.bold)
                        Text("Ruvo is provided 'as is' without warranties of any kind, whether express or implied. We do not guarantee that the App will be error-free or that its content will meet all specific professional artistic requirements.")
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Privacy Policy")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .padding(.top, 10)
                        
                        Text("Last Updated: March 2024")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("1. Data Collection")
                            .fontWeight(.bold)
                        Text("Ruvo is designed as an offline-first tool. We do not collect, store, or transmit any personal information, usage data, or identification metrics from your device.")
                        
                        Text("2. Local Storage")
                            .fontWeight(.bold)
                        Text("Any drawings created in the Scratchpad or progress in the Practice Studio are stored exclusively on your local device. We have no access to your creation data.")
                        
                        Text("3. Third-Party Services")
                            .fontWeight(.bold)
                        Text("The App does not integrate with any third-party analytics, advertising networks, or cloud storage providers that could potentially track user behavior.")
                        
                        Text("4. Children's Privacy")
                            .fontWeight(.bold)
                        Text("As we do not collect any personal data, Ruvo is compliant with COPPA and global children's privacy standards. We do not knowingly target or collect data from minors.")
                    }
                    
                    Text("Contact Information")
                        .fontWeight(.bold)
                    Text("If you have any questions regarding these terms, please contact us via the support channels listed on our store page.")
                        .padding(.bottom, 20)
                }
                .font(.system(size: 14))
                .padding(.horizontal)
            }
            
            if !isReadOnly {
                Button(action: {
                    agreementManager.hasAgreed = true
                }) {
                    Text("I Agree")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationBarTitle(isReadOnly ? "Privacy Policy" : "Agreements", displayMode: .inline)
    }
}
