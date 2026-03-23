import SwiftUI

struct InspirationItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let imageName: String
    let stylistName: String
    let stylistBio: String
}

@available(iOS 14.0, *)
struct StyleFeedExplorer: View {
    @EnvironmentObject var navState: JunipNavigationState
    
    let items = [
        InspirationItem(title: "The Effortless Bob", category: "Trends", imageName: "The Effortless Bob", stylistName: "Elena Rossi", stylistBio: "Master of structural cutting with 12 years of Milan salon experience."),
        InspirationItem(title: "Golden Hour Glow", category: "Coloring", imageName: "Golden Hour Glow", stylistName: "Marcus Chen", stylistBio: "Specialist in organic balayage and sun-kissed aesthetics."),
        InspirationItem(title: "Silk & Symmetry", category: "Straight", imageName: "Silk & Symmetry", stylistName: "Elena Rossi", stylistBio: "Master of structural cutting with 12 years of Milan salon experience."),
        InspirationItem(title: "Ocean Breeze Waves", category: "Styling", imageName: "Ocean Breeze Waves", stylistName: "Sarah Jenkins", stylistBio: "Editorial stylist focusing on effortless, texture-driven looks."),
        InspirationItem(title: "Sculpted Pixie", category: "Modern", imageName: "Sculpted Pixie", stylistName: "Marcus Chen", stylistBio: "Specialist in organic balayage and sun-kissed aesthetics."),
        InspirationItem(title: "Regal Braids", category: "Heritage", imageName: "Regal Braids", stylistName: "Sarah Jenkins", stylistBio: "Editorial stylist focusing on effortless, texture-driven looks.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    headerSection
                    
                    VStack(spacing: 25) {
                        ForEach(items) { item in
                            NavigationLink(destination: StyleArticleDetailedView(item: item)) {
                                MagazineCard(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .background(AppTheme.background.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(Date(), style: .date)
                .font(.caption)
                .foregroundColor(AppTheme.primary)
                .fontWeight(.bold)
            
            Text("Junip Journal")
                .font(AppTheme.titleSemiBold(size: 34))
                .foregroundColor(AppTheme.secondary)
            
            Rectangle()
                .fill(AppTheme.primary)
                .frame(width: 40, height: 4)
                .padding(.top, 2)
        }
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct MagazineCard: View {
    let item: InspirationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                // Background placeholder/tint
                AppTheme.secondary
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(15)
                
                // Real Image Asset
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.category.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(AppTheme.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primary)
                        .cornerRadius(4)
                }
                .padding(15)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(AppTheme.titleSemiBold(size: 24))
                    .foregroundColor(AppTheme.secondary)
                
                Text("Explore the nuance of modern aesthetics and professional care techniques. Read more...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.horizontal, 5)
        }
        .background(Color.white)
        .cornerRadius(15)
    }
}
