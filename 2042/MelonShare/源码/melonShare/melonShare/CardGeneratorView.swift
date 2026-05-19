//
//  CardGeneratorView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI
import UIKit

struct CardGeneratorView: View {
    @ObservedObject private var watchManager = WatchlistManager.shared
    
    @State private var selectedDramaIndex = 0
    @State private var quoteText = "Absolutely stellar storyline! The dramatic payoff and plot twists kept me on the edge of my seat."
    @State private var selectedThemeIndex = 0
    @State private var shareItem: ShareImageItem? = nil
    
    // Four distinct gradient themes using hex codes for compatibility
    let themes = [
        CardTheme(name: "Melon Peach", startHex: "FF6E7D", endHex: "FFA560"),
        CardTheme(name: "Midnight Vengeance", startHex: "5A2878", endHex: "1E1E46"),
        CardTheme(name: "Golden Era", startHex: "FFAA3C", endHex: "B4641E"),
        CardTheme(name: "Emerald Tale", startHex: "3CA082", endHex: "145046")
    ]
    
    var selectedDrama: Drama {
        DramaDatabase.list[selectedDramaIndex]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header
                        ViewHeader(
                            title: "Amway Cards",
                            subtitle: "Share Creator"
                        )
                        
                        // Poster Canvas Card
                        VStack(spacing: 0) {
                            Text("CARD PREVIEW")
                               .font(.caption2)
                                .bold()
                                .foregroundColor(Theme.textLight)
                                .tracking(1)
                                .padding(.bottom, 8)
                             
                            // Visual Poster Canvas
                            VStack(alignment: .leading, spacing: 16) {
                                // Top Brand
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.white)
                                    Text("MelonShare Recommendation")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.white)
                                        .tracking(1)
                                    Spacer()
                                    Image(systemName: selectedDrama.iconName)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                // Quotation Details
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: "quote.opening")
                                        .font(.title)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(quoteText.isEmpty ? "Write your personal recommendation message here..." : quoteText)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                        .lineSpacing(4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .minimumScaleFactor(0.8)
                                }
                                
                                Spacer()
                                
                                // Drama Title info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedDrama.title)
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        Text(selectedDrama.category)
                                            .font(.system(size: 8))
                                            .bold()
                                            .foregroundColor(.white)
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 6)
                                            .background(Color.white.opacity(0.25))
                                            .cornerRadius(4)
                                        
                                        Spacer()
                                        
                                        // Rating representation
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { idx in
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 8))
                                                    .foregroundColor(idx <= Int(selectedDrama.rating.rounded()) ? .orange : .white.opacity(0.3))
                                            }
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(10)
                            }
                            .padding(20)
                            .frame(height: 320)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [themes[selectedThemeIndex].startColor, themes[selectedThemeIndex].endColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(color: themes[selectedThemeIndex].startColor.opacity(0.2), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        
                        // Editor Panel Card
                        GlassCard(padding: 16) {
                            VStack(alignment: .leading, spacing: 14) {
                                  Text("Customize Card Content")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(Theme.textDark)
                                
                                // Premium Drama Selector Row
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Select Short Drama")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(Theme.textMedium)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(0..<DramaDatabase.list.count, id: \.self) { index in
                                                let drama = DramaDatabase.list[index]
                                                let isSelected = selectedDramaIndex == index
                                                
                                                Button(action: {
                                                    withAnimation(.spring()) {
                                                        selectedDramaIndex = index
                                                    }
                                                }) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        HStack {
                                                            Image(systemName: drama.iconName)
                                                                .font(.caption2)
                                                                .foregroundColor(isSelected ? .white : Theme.primaryPeach)
                                                            
                                                            Spacer()
                                                            
                                                            if isSelected {
                                                                Image(systemName: "checkmark.circle.fill")
                                                                    .font(.caption2)
                                                                    .foregroundColor(.white)
                                                            }
                                                        }
                                                        
                                                        Text(drama.title)
                                                            .font(.system(size: 10, weight: .bold))
                                                            .lineLimit(1)
                                                            .foregroundColor(isSelected ? .white : Theme.textDark)
                                                        
                                                        Text(drama.category)
                                                            .font(.system(size: 8))
                                                            .foregroundColor(isSelected ? .white.opacity(0.8) : Theme.textLight)
                                                    }
                                                    .padding(10)
                                                    .frame(width: 140, height: 65)
                                                    .background(isSelected ? Theme.accentGradient : LinearGradient(colors: [Color.white], startPoint: .top, endPoint: .bottom))
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(isSelected ? Color.clear : Theme.borderGray, lineWidth: 1)
                                                    )
                                                    .shadow(color: isSelected ? Theme.accentPink.opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 2)
                                    }
                                }
                                
                                // Quote/Review Editor
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Amway Quote Description")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(Theme.textMedium)
                                    
                                    TextField("Type personal recommendation quote...", text: $quoteText)
                                        .font(.caption)
                                        .padding(10)
                                        .background(Theme.backgroundGray)
                                        .cornerRadius(8)
                                }
                                
                                // Theme Selector
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Card Theme Color")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(Theme.textMedium)
                                    
                                    HStack(spacing: 12) {
                                        ForEach(0..<themes.count, id: \.self) { idx in
                                            Circle()
                                                .fill(LinearGradient(colors: [themes[idx].startColor, themes[idx].endColor], startPoint: .top, endPoint: .bottom))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedThemeIndex == idx ? 2 : 0)
                                                )
                                                .overlay(
                                                    Circle()
                                                        .stroke(Theme.primaryPeach, lineWidth: selectedThemeIndex == idx ? 1.5 : 0)
                                                        .scaleEffect(1.15)
                                                )
                                                .onTapGesture {
                                                    selectedThemeIndex = idx
                                                }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Render and Export buttons
                        PrimaryButton(title: "Share Poster Card", icon: "square.and.arrow.up") {
                            renderAndShareCard()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        
                        Spacer(minLength: 80)
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .background(Theme.backgroundGray)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            }
            .navigationBarHidden(true)
            .sheet(item: $shareItem) { item in
                ShareSheetView(activityItems: [item.image])
            }
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Export Core Graphics Rendering
    private func renderAndShareCard() {
        let cardWidth: CGFloat = 375
        let cardHeight: CGFloat = 500
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cardWidth, height: cardHeight))
        
        let renderedImage = renderer.image { context in
            // Draw Gradient Background
            let uiTheme = themes[selectedThemeIndex]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let cgColors = [UIColor(hexString: uiTheme.startHex).cgColor, UIColor(hexString: uiTheme.endHex).cgColor] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: locations) else { return }
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: cardWidth, y: cardHeight),
                options: []
            )
            
            // Draw Top sparkles/text
            let topTitle = "MelonShare Card"
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85),
                .kern: 1.5
            ]
            topTitle.draw(at: CGPoint(x: 24, y: 24), withAttributes: titleAttr)
            
            // Draw Sparkles symbol via character
            let sparkles = "✦"
            let sparkAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            sparkles.draw(at: CGPoint(x: cardWidth - 36, y: 22), withAttributes: sparkAttr)
            
            // Draw Big Quote Symbols
            let quoteSymbol = "“"
            let quoteSymAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia-Bold", size: 64) ?? UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: UIColor.white.withAlphaComponent(0.3)
            ]
            quoteSymbol.draw(at: CGPoint(x: 24, y: 60), withAttributes: quoteSymAttr)
            
            // Draw Quote Text
            let quoteParagraph = NSMutableParagraphStyle()
            quoteParagraph.lineSpacing = 6
            let quoteAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.white,
                .paragraphStyle: quoteParagraph
            ]
            
            let quoteRect = CGRect(x: 28, y: 130, width: cardWidth - 56, height: 180)
            quoteText.draw(in: quoteRect, withAttributes: quoteAttr)
            
            // Draw bottom translucent card backing
            let bottomBackRect = CGRect(x: 20, y: 350, width: cardWidth - 40, height: 110)
            let path = UIBezierPath(roundedRect: bottomBackRect, cornerRadius: 14)
            UIColor.black.withAlphaComponent(0.15).setFill()
            path.fill()
            
            // Draw Drama Title
            let dramaTitleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white
            ]
            selectedDrama.title.draw(at: CGPoint(x: 36, y: 365), withAttributes: dramaTitleAttr)
            
            // Draw Category
            let categoryAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor: UIColor(red: 255/255, green: 110/255, blue: 125/255, alpha: 1.0)
            ]
            
            // Draw category background capsule
            let categoryText = " \(selectedDrama.category) "
            let categorySize = categoryText.size(withAttributes: categoryAttr)
            let capPath = UIBezierPath(roundedRect: CGRect(x: 36, y: 395, width: categorySize.width + 10, height: 18), cornerRadius: 4)
            UIColor.white.setFill()
            capPath.fill()
            
            categoryText.draw(at: CGPoint(x: 41, y: 397), withAttributes: categoryAttr)
            
            // Draw Stars representation
            let stars = String(repeating: "★", count: Int(selectedDrama.rating.rounded()))
            let starsAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.orange
            ]
            stars.draw(at: CGPoint(x: cardWidth - 110, y: 397), withAttributes: starsAttr)
            
            // Draw Bottom Brand stamp
            let stamp = "Best Short Drama Companion App - MelonShare"
            let stampAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .kern: 0.8
            ]
            stamp.draw(at: CGPoint(x: 36, y: 432), withAttributes: stampAttr)
        }
        
        self.shareItem = ShareImageItem(image: renderedImage)
    }
}

// Struct to represent the dynamic shared image item
struct ShareImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

// Data holder representing our poster gradient settings using hex codes
struct CardTheme {
    let name: String
    let startHex: String
    let endHex: String
    
    var startColor: Color { Color(hexString: startHex) }
    var endColor: Color { Color(hexString: endHex) }
}

// iPad & iOS 13 compatible Share Sheet Swift UI bridge using UIActivityViewController
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        // Prevent crashes/blank screens on iPads and Mac Catalyst targets
        if let popover = controller.popoverPresentationController {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first {
                popover.sourceView = window.rootViewController?.view
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No dynamic updates needed
    }
}

struct CardGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        CardGeneratorView()
    }
}
