import SwiftUI

@available(iOS 14.0, *)
struct StyleArticleDetailedView: View {
    let item: InspirationItem
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingChat = false
    @State private var showingReportAlert = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Background NavigationLink for the chat
                    NavigationLink(destination: JunipConciergeView(stylistName: item.stylistName), isActive: $isShowingChat) {
                        EmptyView()
                    }
                    
                    ZStack(alignment: .topLeading) {
                        AppTheme.secondary
                            .aspectRatio(4/3, contentMode: .fill)
                            .cornerRadius(0)
                        
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    }
                    .frame(height: 300)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // ... existing info content ...
                        Text(item.category.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                        
                        Text(item.title)
                            .font(AppTheme.titleSemiBold(size: 30))
                            .foregroundColor(AppTheme.text)
                        
                        Text("Professional Styling Guide")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Divider().padding(.vertical, 10)
                        
                        Text("About this style")
                            .font(.headline)
                        
                        Text("This unique look is perfect for those seeking both elegance and low maintenance. Our stylists recommend using light volume mouse and a medium heat blow-dry to achieve the best results. \n\nThe \(item.title) works exceptionally well with \(item.category) and can be adapted for both casual and formal occasions.")
                            .font(AppTheme.bodyRegular(size: 16))
                            .lineSpacing(6)
                            .foregroundColor(.gray)
                        
                        Divider().padding(.vertical, 20)
                        
                        StylistProfileCard(name: item.stylistName, bio: item.stylistBio) {
                            // Action to consult
                            isShowingChat = true // Trigger push navigation
                        }
                        
                        Button(action: {
                            withAnimation { showingReportAlert = true }
                        }) {
                            Text("Report this content")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            
            if showingReportAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showingReportAlert = false }
                
                VStack(spacing: 20) {
                    Image(systemName: "flag.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary)
                    
                    Text("Content Reported")
                        .font(AppTheme.titleSemiBold(size: 22))
                    
                    Text("Thank you for flagging this article. Our quality team will review the content and stylist information within 24 hours.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button(action: { 
                        withAnimation { showingReportAlert = false }
                    }) {
                        Text("Dismiss")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 40)
                .shadow(radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(item.title)
    }
}
    
@available(iOS 14.0, *)
struct StylistProfileCard: View {
    let name: String
    let bio: String
    let consultAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                Circle()
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(AppTheme.primary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(AppTheme.titleSemiBold(size: 20))
                    Text("Lead Stylist")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text(bio)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Button(action: consultAction) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Consult with \(name.split(separator: " ").first ?? "Expert")")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
