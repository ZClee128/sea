import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct SettingsView: View {
    @State private var showingPrivacy = false
    @State private var showingStore = false
    @ObservedObject var coinManager = CoinManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                        Text("Trilo Coins")
                        Spacer()
                        Text("\(coinManager.balance)")
                            .fontWeight(.bold)
                    }
                    
                    Button(action: {
                        showingStore = true
                    }) {
                        HStack {
                            Text("Top Up Coins")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Trilo")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Legal")) {
                    Button(action: {
                        showingPrivacy = true
                    }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("About Trilo")) {
                    Text("Trilo is your personal focus companion. Combine high-quality visual inspirations with ambient soundscapes to create the perfect environment for productivity and relaxation.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacy) {
                VStack {
                    HStack {
                        Spacer()
                        Button("Done") {
                            showingPrivacy = false
                        }
                        .padding()
                    }
                    HTMLView(fileName: "privacy")
                }
            }
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
        }
    }
}

@available(iOS 15.0, *)
struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var storeManager = StoreManager.shared
    
    // Fallback names/coins if products haven't loaded yet
    let coinData: [String: (name: String, coins: Int)] = [
        "Trilo": ("32 coins", 32),
        "Trilo1": ("60 coins", 60),
        "Trilo2": ("96 coins", 96),
        "Trilo4": ("155 coins", 155),
        "Trilo5": ("189 coins", 189),
        "Trilo9": ("359 coins", 359),
        "Trilo19": ("729 coins", 729),
        "Trilo49": ("1869 coins", 1869),
        "Trilo99": ("3799 coins", 3799)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                            .padding(.top, 20)
                        Text("Get Trilo Coins")
                            .font(.title2.bold())
                        Text("Unlock exclusive premium moods and sounds")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if storeManager.products.isEmpty {
                        ProgressView("Loading store...")
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(storeManager.products, id: \.id) { product in
                                Button(action: {
                                    Task {
                                        try? await storeManager.purchase(product)
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(coinData[product.id]?.name ?? product.displayName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(product.displayPrice)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Restoring purchases will recover your coin balance if you reinstall the app.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Restore Purchases") {
                            Task {
                                try? await AppStore.sync()
                            }
                        }
                        .font(.caption.bold())
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Trilo Store")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
