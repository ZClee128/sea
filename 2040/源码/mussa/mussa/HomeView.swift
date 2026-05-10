import SwiftUI

// Manual definition for iOS 15 colors to support iOS 13
extension Color {
    static let ios13Teal = Color(red: 48/255, green: 176/255, blue: 199/255)
    static let ios13Indigo = Color(red: 88/255, green: 86/255, blue: 214/255)
    static let ios13Cyan = Color(red: 50/255, green: 173/255, blue: 230/255)
}

struct HomeView: View {
    @ObservedObject var store: AuraStore
    @ObservedObject var chatManager: ChatManager
    @State private var selectedItem: AuraItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Header with more generous spacing
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CRYSTAL AURAS")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.blue)
                                .tracking(3)
                            
                            Text("Discover Your Mussa")
                                .font(.system(size: 34, weight: .bold)) // Slightly smaller font
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 60) // Increased top padding for safe area
                        
                        VStack(spacing: 25) {
                            ForEach(store.items) { item in
                                AuraCard(item: item)
                                    .onTapGesture {
                                        selectedItem = item
                                    }
                            }
                        }
                        .padding(.bottom, 100) // Increased bottom padding to clear TabBar
                    }
                }
                .edgesIgnoringSafeArea(.top) // Allow scroll to top
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                if #available(iOS 14.0, *) {
                    AuraDetailView(item: item, store: store, chatManager: chatManager)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for iPad/Large screens
    }
}

struct AuraCard: View {
    let item: AuraItem
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                // Main Image with fixed frame and clipping to avoid distortion
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 450) // Reduced height slightly
                    .clipped()
                    .cornerRadius(32)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                            .cornerRadius(32)
                    )
                
                // Content Overlay
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(item.rarity.uppercased())
                            .font(.system(size: 11, weight: .black))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Spacer()
                        if #available(iOS 14.0, *) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundColor(.yellow)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.museName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(item.title)
                            .font(.system(size: 28, weight: .bold)) // Slightly smaller
                            .foregroundColor(.white)
                        
                        if #available(iOS 14.0, *) {
                            HStack(spacing: 6) {
                                Image(systemName: "pentagon.fill")
                                    .font(.caption2)
                                Text("Unlock with \(item.unlockCost) shards")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 5)
                        }
                    }
                }
                .padding(25)
            }
        }
        .padding(.horizontal, 25)
        .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 10)
    }
}
