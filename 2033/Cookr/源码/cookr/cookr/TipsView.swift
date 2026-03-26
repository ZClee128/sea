import SwiftUI

// --- Models ---
struct CookingTip: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let tips: [TipItem]
}

struct TipItem: Identifiable {
    let id = UUID()
    let headline: String
    let body: String
}

// --- Data ---
let cookingTips: [CookingTip] = [
    CookingTip(title: "Knife Skills", icon: "🔪", color: .red, tips: [
        TipItem(headline: "Keep Your Blade Sharp", body: "A dull knife is more dangerous than a sharp one. Hone your knife every few uses and sharpen it every few months with a whetstone."),
        TipItem(headline: "The Claw Grip", body: "Curl your fingertips inward, letting the knuckles guide the blade. This technique prevents cuts and gives you precise control."),
        TipItem(headline: "Rocking Motion", body: "Keep the tip of the knife on the board and use a rocking motion for herbs and garlic — faster and safer than lifting the whole blade."),
        TipItem(headline: "Board Stability", body: "Place a damp towel under your cutting board to stop it sliding. Stability equals safety and precision."),
    ]),
    CookingTip(title: "Heat Mastery", icon: "🔥", color: .orange, tips: [
        TipItem(headline: "The Sizzle Test", body: "Add a drop of water to a hot pan. If it immediately evaporates with a loud sizzle, the pan is ready for searing."),
        TipItem(headline: "Don't Crowd the Pan", body: "Overcrowding lowers the pan temperature, causing food to steam instead of sear. Cook in batches when needed."),
        TipItem(headline: "Residual Heat", body: "Turn off the heat a minute early. The pan stays hot and finishes the cooking — preventing overcooking."),
        TipItem(headline: "Low and Slow", body: "Tough cuts like brisket and lamb shoulder become tender and succulent only with gentle, prolonged heat — never high and fast."),
    ]),
    CookingTip(title: "Seasoning Secrets", icon: "🧂", color: .blue, tips: [
        TipItem(headline: "Season in Layers", body: "Add salt at each stage of cooking — not just at the end. Layer by layer seasoning builds depth and complexity."),
        TipItem(headline: "Taste as You Go", body: "The best chefs taste constantly. Adjust seasoning incrementally, not all at once."),
        TipItem(headline: "Acid is Your Friend", body: "A squeeze of lemon or splash of vinegar at the end brightens a dish and balances richness. Try it on everything."),
        TipItem(headline: "Fat Carries Flavour", body: "Season fatty ingredients more generously — fat coats the tongue and can mute salt perception."),
    ]),
    CookingTip(title: "Plating Like a Pro", icon: "🍽️", color: .purple, tips: [
        TipItem(headline: "Odd Numbers", body: "Three or five elements on a plate look more natural to the eye than even numbers. Pair ingredients in odd clusters."),
        TipItem(headline: "White Space", body: "Leave part of the plate bare. Busy plates look amateur; negative space gives the food room to breathe."),
        TipItem(headline: "Height and Texture", body: "Vary the height and texture of components. A flat plate feels 2D — stack, lean, or propp elements for visual interest."),
        TipItem(headline: "Wipe the Rim", body: "Always clean the rim of the plate before serving. A stray drop of sauce breaks the illusion of a fine dining experience."),
    ]),
    CookingTip(title: "Baking Science", icon: "🧁", color: .pink, tips: [
        TipItem(headline: "Room Temperature Ingredients", body: "Butter, eggs and milk should be at room temperature before mixing. Cold fat doesn't cream properly and cold eggs can split a batter."),
        TipItem(headline: "Don't Overmix", body: "Once you add flour, mix only until combined. Overmixing develops gluten, making cakes tough and dense."),
        TipItem(headline: "Measure by Weight", body: "Use a kitchen scale, not cups. A cup of flour can weigh anywhere between 120g and 180g depending on how it's scooped."),
        TipItem(headline: "The Toothpick Test", body: "Insert a toothpick into the centre of a cake. If it comes out with a few moist crumbs (not wet batter), it's done."),
    ]),
    CookingTip(title: "Sauce Fundamentals", icon: "🥄", color: .green, tips: [
        TipItem(headline: "The Five Mother Sauces", body: "Classic French cuisine is built on five: Béchamel, Velouté, Espagnole, Tomato, and Hollandaise. Master these and hundreds of sauces follow."),
        TipItem(headline: "Roux Ratio", body: "A classic roux is equal parts butter and flour by weight. Cook it out for 2 minutes before adding liquid to remove the raw flour taste."),
        TipItem(headline: "Reducing for Flavour", body: "Simmer a sauce uncovered to concentrate its flavours. The liquid evaporates but the flavour compounds remain."),
        TipItem(headline: "Monte au Beurre", body: "Finish a sauce by whisking in cold butter off the heat. It adds richness, shine, and emulsifies the sauce beautifully."),
    ]),
]

// --- Views ---
@available(iOS 14.0, *)
struct TipsView: View {
    var body: some View {
        NavigationView {
            List(cookingTips) { category in
                NavigationLink(destination: TipCategoryView(category: category)) {
                    HStack(spacing: 14) {
                        Text(category.icon)
                            .font(.system(size: 32))
                            .frame(width: 52, height: 52)
                            .background(category.color.opacity(0.12))
                            .cornerRadius(12)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(category.title)
                                .font(.headline)
                            Text("\(category.tips.count) tips")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Cooking Tips")
        }
    }
}

@available(iOS 14.0, *)
struct TipCategoryView: View {
    let category: CookingTip
    @State private var expanded: Set<UUID> = []

    var body: some View {
        List(category.tips) { tip in
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    if expanded.contains(tip.id) {
                        expanded.remove(tip.id)
                    } else {
                        expanded.insert(tip.id)
                    }
                }) {
                    HStack {
                        Text(tip.headline)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: expanded.contains(tip.id) ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())

                if expanded.contains(tip.id) {
                    Text(tip.body)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                        .transition(.opacity)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(category.title)
        .accentColor(category.color)
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View { if #available(iOS 14.0, *) {
        TipsView()
    } else {
        // Fallback on earlier versions
    } }
}
