import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinShopView: View {
    @StateObject var storeManager = StoreManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var errorMessage: String? = nil
    @State private var showingError = false
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
                        
                        HStack {
                            Text("Coin Boutique")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if storeManager.isFetching {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            }
                        }
                        .padding(.horizontal)

                        // StoreKit Status Info (Helpful for Reviewers)
                        if !storeManager.isFetching && storeManager.products.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                
                                Text("Store Synchronization Pending")
                                    .font(.system(size: 16, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                
                                Text("We're having trouble connecting to the App Store. Please ensure your device has a valid network connection and sandbox account.")
                                    .font(.system(size: 12, design: .serif))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: { Task { await storeManager.fetchProducts() } }) {
                                    Text("Retry Connection")
                                        .font(.system(size: 14, weight: .bold, design: .serif))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.yellow)
                                        .cornerRadius(20)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
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
                                .disabled(purchasingID != nil || (storeManager.products.isEmpty && !storeManager.isFetching))
                                .opacity(storeManager.products.isEmpty && !storeManager.isFetching ? 0.5 : 1.0)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        Text("All purchases are processed securely via Apple.")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { Task { try? await AppStore.sync() } }) {
                            Text("Restore Purchases")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .foregroundColor(.white.opacity(0.5))
                                .underline()
                        }
                        .padding(.bottom, 20)
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
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Boutique Unavailable"),
                    message: Text(errorMessage ?? "Please check your network connection or try again later."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func purchase(_ id: String) {
        // Ensure product exists in fetched products
        guard storeManager.products.contains(where: { $0.id == id }) else {
            errorMessage = "This package is currently unavailable in your region or storefront. Please try another one."
            showingError = true
            return
        }

        withAnimation { purchasingID = id }
        triggerHaptic()
        
        Task {
            do {
                try await storeManager.purchase(id)
                triggerHapticSuccess()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
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
