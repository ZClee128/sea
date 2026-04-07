import SwiftUI

@available(iOS 14.0, *)
struct ContributionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let spot: DiscoverySpot
    
    @State private var showingNoCoinsAlert = false
    @State private var showingStore = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 35) {
                // 1. Hero Artwork (User Photo or Procedural)
                ZStack {
                    if let data = spot.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 350)
                            .clipped()
                    } else {
                        Color.black
                            .frame(width: UIScreen.main.bounds.width, height: 350)
                        
                        VStack(spacing: 20) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.2))
                            Text("CURATION DRAFT")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white.opacity(0.4))
                                .tracking(8)
                        }
                    }
                }
                
                // 2. Status Badge & Boost
                VStack(spacing: 20) {
                    HStack {
                        Text("STATUS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        Spacer()
                        
                        if spot.isBoosted {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill").foregroundColor(.yellow)
                                Text("FEATURED SPOT")
                                    .font(.system(size: 10, weight: .black))
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(5)
                        } else {
                            HStack(spacing: 6) {
                                Circle().fill(Color.orange).frame(width: 8, height: 8)
                                Text("UNDER REVIEW")
                                    .font(.system(size: 10, weight: .black))
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(5)
                        }
                    }
                    
                    if !spot.isBoosted {
                        Button(action: {
                            if CollectionManager.shared.coinBalance >= 100 {
                                CollectionManager.shared.boostSpot(id: spot.id)
                            } else {
                                showingNoCoinsAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("BOOST DISCOVERY")
                                    .padding(.leading, 5)
                                Spacer()
                                Text("100 COINS").font(.system(size: 10, weight: .black))
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14).padding(.horizontal, 20)
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .alert(isPresented: $showingNoCoinsAlert) {
                    Alert(
                        title: Text("Insufficient Coins"),
                        message: Text("Each boost requires 100 Popla Coins. Visit the store to top up."),
                        primaryButton: .default(Text("Visit Store")) {
                            showingStore = true
                        },
                        secondaryButton: .cancel()
                    )
                }
                .fullScreenCover(isPresented: $showingStore) {
                    if #available(iOS 15.0, *) {
                        PoplaStoreView()
                    }
                }
                
                // 3. Discovery Details
                VStack(alignment: .leading, spacing: 10) {
                    Text(spot.title)
                        .font(.system(size: 32, weight: .black))
                    
                    Text(spot.category.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                        .tracking(3)
                }
                .padding(.horizontal, 30)
                
                // 4. Submission Log
                VStack(alignment: .leading, spacing: 20) {
                    Text("SUBMISSION LOG")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    LogItemRow(date: "JULY 07, 2026", event: "Spot discovery submitted by curator.")
                    LogItemRow(date: "JULY 07, 2026", event: "Visual assets processing.")
                    LogItemRow(date: "PENDING", event: "Editorial review for the Daily Board.")
                }
                .padding(.horizontal, 30)
                
                Spacer().frame(height: 50)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .overlay(
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 50) // Professional safe padding
                    Spacer()
                }
                Spacer()
            },
            alignment: .top
        )
    }
}

struct LogItemRow: View {
    let date: String
    let event: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(date).font(.system(size: 10, weight: .bold))
            Text(event).font(.system(size: 14)).foregroundColor(.gray)
        }
    }
}
