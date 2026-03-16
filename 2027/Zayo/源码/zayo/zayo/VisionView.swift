import SwiftUI

struct VisionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Header Image/Icon Section
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "eye.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                    }
                    
                    Text("Elevating the Art\nof Portraiture")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                }
                .padding(.top, 40)
                
                // Mission Sections
                VStack(alignment: .leading, spacing: 32) {
                    VisionCard(
                        title: "The Artistic Eye",
                        content: "Zayo is born from a desire to celebrate the human form through the lens of fine art. We believe every portrait tells a silent story of emotion, light, and shadow.",
                        icon: "sparkles"
                    )
                    
                    VisionCard(
                        title: "Technical Excellence",
                        content: "Beyond mere imagery, we are dedicated to the 'how'. Our mission is to demystify complex lighting setups and provide a bridge between inspiration and technical mastery.",
                        icon: "lightbulb"
                    )
                    
                    VisionCard(
                        title: "A Digital Sanctuary",
                        content: "In an age of endless scrolling, Zayo offers a curated sanctuary—a place where quality triumphs over quantity, and where photography is treated as the high art it truly is.",
                        icon: "leaf.fill"
                    )
                }
                .padding(.horizontal, 24)
                
                Divider()
                    .padding(.horizontal, 40)
                
                Text("“Photography is the beauty of life, captured.”")
                    .font(.system(size: 18, weight: .black, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 60)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct VisionCard: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary.opacity(0.7))
                    .lineSpacing(4)
            }
        }
    }
}

struct VisionView_Previews: PreviewProvider {
    static var previews: some View {
        VisionView()
    }
}
