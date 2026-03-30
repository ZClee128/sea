import SwiftUI

@available(iOS 15.0, *)
struct ArticleDetailView: View {
    let article: ArticleItem
    
    // 示范性的图文正文内容（由于没有传入，此处用长文本占位展示排版）
    private let dummyContent = """
    Proper nutrition is the cornerstone of any effective fitness regimen. It doesn't matter how hard you train if your body lacks the building blocks needed for recovery and growth.
    
    ### 1. The Pre-Workout Window
    Timing is everything. Consuming a balanced meal of complex carbohydrates and lean proteins about 2 hours before your workout ensures a steady release of energy.

    ### 2. Hydration is Non-Negotiable
    A mere 2% drop in hydration can lead to a 10% drop in performance. Make sure to drink water consistently throughout the day, not just during your session.

    ### 3. Protein Pacing
    Aiming for 20-30g of high-quality protein every 3-4 hours maximizes muscle protein synthesis.

    *Consistency and balance are the keys to long-term success.*
    """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 顶部头图
                ZStack {
                    LinearGradient(
                        colors: [Color.green.opacity(0.15), Color.blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 80))
                        .foregroundColor(Color.green.opacity(0.5))
                        .shadow(color: Color.green.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 280)
                .clipped()

                // 内容区
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Text(article.category)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(Color.green)
                            .cornerRadius(6)

                        Text("·")
                            .foregroundColor(Color.gray)

                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(article.readTime)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color.gray)
                    }
                    .padding(.top, 24)

                    Text(article.title)
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(Color(hex: "#1D1D2B")) // zText
                        .fixedSize(horizontal: false, vertical: true)

                    Text(article.subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 10)

                    Divider()

                    // 文章正文
                    Text(dummyContent)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "#4A4A5A"))
                        .lineSpacing(8)
                        .padding(.top, 10)
                        
                    Spacer(minLength: 120) // 底部留白
                }
                .padding(.horizontal, 20)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 动态提取图文头图
    private var categoryIcon: String {
        switch article.category.lowercased() {
        case "nutrition": return "leaf.fill"
        case "recovery": return "bed.double.fill"
        case "mindset", "focus": return "brain.head.profile"
        default: return "book.fill"
        }
    }
}
