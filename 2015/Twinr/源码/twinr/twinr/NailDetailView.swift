import SwiftUI

@available(iOS 14.0, *)
struct NailDetailView: View {
    let design: NailDesign
    @ObservedObject var storeManager = StoreManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var isUnlocked: Bool {
        !design.isPremium || storeManager.isUnlocked(design.name)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Showcase
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.1), .purple.opacity(0.2)]), 
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 380)
                    
                    VStack {
                    Image(design.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 380)
                        .clipped()
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.3), .clear]), startPoint: .bottom, endPoint: .center)
                        )
                        
                        Text(design.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        Text(design.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(20)
                    }
                }
                
                ZStack {
                    VStack(alignment: .leading, spacing: 25) {
                        // Quick Info
                        HStack(spacing: 30) {
                            InfoItem(icon: "clock.fill", label: "45-60 min", color: .blue)
                            InfoItem(icon: "chart.bar.fill", label: "Intermediate", color: .purple)
                            InfoItem(icon: "heart.fill", label: "Popular", color: .pink)
                        }
                        .padding(.top, 25)
                        
                        // Design Concept
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Design Concept")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(design.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }
                        
                        // Application Steps (Addressing Guideline 4.2)
                        VStack(alignment: .leading, spacing: 15) {
                            Text("How to Apply")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            ForEach(0..<3) { index in
                                StepRow(number: index + 1, text: stepForIndex(index))
                            }
                        }
                        
                        // Pro Tip
                        VStack(alignment: .leading, spacing: 10) {
                            Label {
                                Text("Pro Tip")
                                    .font(.headline)
                            } icon: {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                            }
                            
                            Text("For a more professional finish, apply a thin layer of top coat every 2-3 days to keep the shine and prevent chipping.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 40)
                    .blur(radius: isUnlocked ? 0 : 12)
                    
                    if !isUnlocked {
                        VStack(spacing: 20) {
                            Image(systemName: "lock.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.pink)
                            
                            Text("Exclusive Pro Design")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Unlock this premium tutorial and master the latest nail art techniques.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                if storeManager.spendCoins(design.price) {
                                    storeManager.unlockDesign(design.name)
                                } else {
                                    alertMessage = "Not enough coins! Visit the store to top up."
                                    showingAlert = true
                                }
                            }) {
                                Text("Unlock for \(design.price) Coins")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 15)
                                    .background(Color.pink)
                                    .cornerRadius(30)
                                    .shadow(radius: 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .padding()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Insufficient Balance"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func stepForIndex(_ index: Int) -> String {
        let steps = [
            "Prepare your nails by filing and buffing the surface gently for better adhesion.",
            "Apply a thin base coat and cure it under UV light for 60 seconds.",
            "Carefully paint the design using a fine nail brush and seal with a high-gloss top coat."
        ]
        return steps[index]
    }
}

struct InfoItem: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.pink.opacity(0.8)))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

