import SwiftUI

@available(iOS 15.0, *)
struct ExploreView: View {
    @StateObject var assetManager = AssetManager()
    @ObservedObject var personaManager = PersonaManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Aesthetic Persona Header
                    if personaManager.currentPersona == .undiagnosed {
                        NavigationLink(destination: AestheticIQView()) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Aesthetic DNA")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Text("Discover Your IQ")
                                            .font(.system(size: 24, weight: .bold, design: .serif))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Image(systemName: "sparkles")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                                
                                Text("Take the interactive quiz to unlock a personalized viewing experience.")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(24)
                            .background(
                                LinearGradient(colors: [.black, .gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                    } else {
                        // Personalized Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: PersonaManager.shared.currentPersona.icon)
                                    .foregroundColor(PersonaManager.shared.currentPersona.themeColor)
                                Text("Persona Selection")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            Text("Curated for \(PersonaManager.shared.currentPersona.rawValue)")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(assetManager.muses.shuffled().prefix(3)) { muse in
                                        FeaturedMuseCard(muse: muse)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    // Daily Aesthetic Pulse (Dynamic Logic)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Aesthetic Pulse")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("INTENT FOR \(dayString())")
                                        .font(.system(size: 10, weight: .black))
                                        .tracking(2)
                                        .foregroundColor(.secondary)
                                    
                                    Text(dailyIntent())
                                        .font(.system(size: 18, weight: .bold, design: .serif))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                Image(systemName: "circle.dotted")
                                    .font(.title2)
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            
                            // Daily Palette
                            HStack(spacing: 12) {
                                ForEach(dailyPalette(), id: \.self) { hex in
                                    Rectangle()
                                        .fill(Color(hex: hex))
                                        .frame(height: 10)
                                        .cornerRadius(5)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemGray6).opacity(0.4))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)

                    // Editorial Muses
                    Text("Editorial Muses")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(assetManager.muses.filter { $0.isEditorialFeatured }) { muse in
                                FeaturedMuseCard(muse: muse)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main Grid
                    Text("Collections")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    VStack(spacing: 20) {
                        ForEach(assetManager.muses.filter { !$0.isEditorialFeatured }) { muse in
                            NavigationLink(destination: MuseDetailView(muse: muse)) {
                                MuseEditorialCard(muse: muse)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Fickr Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Deterministic Daily Logic
    private func dayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date()).uppercased()
    }
    
    private func dailyIntent() -> String {
        let intents = [
            "Embrace the subtle nuances of morning light.",
            "Find structure in the chaos of urban shadows.",
            "Let the organic flow of nature guide your vision.",
            "Discover the vibrant energy of saturated moments.",
            "Seek the stillness in monochromatic depths.",
            "Celebrate the delicate rebirth of spring vibes.",
            "Deconstruct the architecture of your environment."
        ]
        let day = Calendar.current.component(.day, from: Date())
        return intents[day % intents.count]
    }
    
    private func dailyPalette() -> [String] {
        let palettes = [
            ["#2F4F4F", "#556B2F", "#8FBC8F"],
            ["#191970", "#000080", "#4B0082"],
            ["#FFB6C1", "#ADD8E6", "#F0FFF0"],
            ["#FFD700", "#F4A460", "#DAA520"],
            ["#4682B4", "#708090", "#B0C4DE"],
            ["#CCCCCC", "#888888", "#FFFFFF"],
            ["#FF00FF", "#800080", "#0000FF"]
        ]
        let day = Calendar.current.component(.day, from: Date())
        return palettes[day % palettes.count]
    }
}

@available(iOS 15.0, *)
struct FeaturedMuseCard: View {
    let muse: MuseItem
    
    var body: some View {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        NavigationLink(destination: MuseDetailView(muse: muse)) {
            ZStack(alignment: .bottomLeading) {
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isPad ? 400 : 280, height: isPad ? 500 : 350)
                    .clipped()
                    .cornerRadius(24)
                
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
                    .cornerRadius(24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(muse.category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(muse.title)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                }
                .padding(20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MuseEditorialCard: View {
    let muse: MuseItem
    
    var body: some View {
        HStack(spacing: 16) {
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 130)
                    .clipped()
                    .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(muse.category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                
                Text(muse.title)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(.black)
                
                Text(muse.description)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

@available(iOS 15.0, *)
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
