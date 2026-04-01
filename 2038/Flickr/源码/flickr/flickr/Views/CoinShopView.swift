import SwiftUI

@available(iOS 15.0, *)
struct CoinShopView: View {
    @StateObject var storeManager = StoreManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var purchasingID: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Balance Card
                        VStack(spacing: 8) {
                            Text("Current Balance")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(storeManager.coinBalance)")
                                    .font(.system(size: 40, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal)
                        
                        Text("Coin Boutique")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Coin Packages Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(storeManager.coinPackages) { package in
                                Button(action: { purchase(package.id) }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "circle.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.yellow)
                                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                                        
                                        VStack(spacing: 4) {
                                            Text(package.name)
                                                .font(.system(size: 18, weight: .bold, design: .serif))
                                                .foregroundColor(.white)
                                            
                                            Text(package.price)
                                                .font(.system(size: 14, design: .serif))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(purchasingID == package.id ? Color.yellow : Color.clear, lineWidth: 2)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(purchasingID != nil)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        Text("All purchases are processed securely via Apple.")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            })
        }
    }
    
    private func purchase(_ id: String) {
        withAnimation { purchasingID = id }
        triggerHaptic()
        
        Task {
            do {
                try await storeManager.purchase(id)
                triggerHapticSuccess()
            } catch {
                print("Purchase failed: \(error)")
            }
            withAnimation { purchasingID = nil }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func triggerHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

@available(iOS 15.0, *)
struct CoinShopView_Previews: PreviewProvider {
    static var previews: some View {
        CoinShopView()
    }
}
