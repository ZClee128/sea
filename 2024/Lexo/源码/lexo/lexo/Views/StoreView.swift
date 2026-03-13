import SwiftUI

@available(iOS 14.0, *)
struct StoreView: View {
    @ObservedObject var appState: AppState
    @StateObject private var storeManager = StoreManager()
    @Environment(\.presentationMode) var presentationMode
    
    // State for showing a loading alert or success alert
    @State private var isPurchasing = false
    @State private var purchaseSuccessAlert = false
    @State private var justBoughtCoins = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // Header - Coins Balance
                VStack(spacing: 10) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.yellow)
                    
                    Text("Your Balance: \(appState.totalCoins) Coins")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Unlock premium tutorials and content with coins.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                
                // Store Packages Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(storeManager.packages) { package in
                        CoinPackageCard(package: package) {
                            purchase(package: package)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                Button("Restore Purchases") {
                    storeManager.restoreProducts()
                }
                .font(.footnote)
                .foregroundColor(.accentColor)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle("Premium Store", displayMode: .inline)
        .onAppear {
            storeManager.getProducts()
        }
        .alert(isPresented: $purchaseSuccessAlert) {
            Alert(
                title: Text("Payment Successful"),
                message: Text("You have successfully purchased \(justBoughtCoins) coins!"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .overlay(
            Group {
                if isPurchasing {
                    ZStack {
                        Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                        if #available(iOS 14.0, *) {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                Text("Processing...")
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            }
                            .padding(30)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                            .cornerRadius(15)
                        } else {
                            Text("Processing...")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        )
    }
    
    private func purchase(package: CoinPackage) {
        isPurchasing = true
        storeManager.purchase(package) { coinsToAdd in
            // Must update on main thread
            DispatchQueue.main.async {
                isPurchasing = false
                appState.totalCoins += coinsToAdd
                justBoughtCoins = package.totalCoins
                purchaseSuccessAlert = true
            }
        }
    }
}

struct CoinPackageCard: View {
    let package: CoinPackage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Gold coin icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 30, height: 30)
                    Image(systemName: "centsign")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(package.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if package.bonusCoins > 0 {
                        Text("+\(package.bonusCoins) Bonus")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                
                Text(package.price)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
