import SwiftUI

@available(iOS 14.0, *)
struct StyleRadarView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    @State private var isAnalyzing = false
    @State private var analysisProgress: CGFloat = 0.0
    @State private var selectedOptions: [String] = []
    @State private var showResults = false
    
    let questions = [
        StyleQuestion(text: "WHAT IS YOUR OPERATING ENVIRONMENT?", options: ["URBAN GRID", "DEEP SEA", "CYBER SPACE"]),
        StyleQuestion(text: "SELECT YOUR ENERGY FREQUENCY", options: ["STATIC", "PULSE", "KINETIC"]),
        StyleQuestion(text: "CHOOSE YOUR CORE MATERIAL", options: ["BIO-SILK", "LED WEAVE", "CARBON FIBER"])
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("CANDYR AI: STYLE RADAR")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(NeonCouture.secondary)
                Spacer()
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(NeonCouture.primary)
            }
            .padding()
            .background(Color.white)
            
            if isAnalyzing {
                AnalysisView(progress: $analysisProgress)
                    .onAppear {
                        startAnalysis()
                    }
            } else if showResults {
                RadarResultsView(dismiss: { presentationMode.wrappedValue.dismiss() })
            } else {
                QuizView(step: $currentStep, questions: questions, selectAction: handleSelection)
            }
        }
        .navigationBarHidden(true)
        .background(NeonCouture.background.edgesIgnoringSafeArea(.all))
    }
    
    func handleSelection(_ option: String) {
        selectedOptions.append(option)
        if currentStep < questions.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            withAnimation {
                isAnalyzing = true
            }
        }
    }
    
    func startAnalysis() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            analysisProgress += 0.02
            if analysisProgress >= 1.0 {
                timer.invalidate()
                withAnimation {
                    isAnalyzing = false
                    showResults = true
                }
            }
        }
    }
}

struct StyleQuestion {
    let text: String
    let options: [String]
}

struct QuizView: View {
    @Binding var step: Int
    let questions: [StyleQuestion]
    let selectAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("STEP 0\(step + 1)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(NeonCouture.primary)
                
                Text(questions[step].text)
                    .font(.system(size: 28, weight: .black, design: .serif))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 30)
            
            VStack(spacing: 16) {
                ForEach(questions[step].options, id: \.self) { option in
                    Button(action: {
                        selectAction(option)
                    }) {
                        Text(option)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Progress Bar
            HStack(spacing: 8) {
                ForEach(0..<questions.count) { i in
                    Capsule()
                        .fill(i <= step ? NeonCouture.primary : Color.gray.opacity(0.2))
                        .frame(width: i == step ? 40 : 20, height: 6)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

struct AnalysisView: View {
    @Binding var progress: CGFloat
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [NeonCouture.primary, NeonCouture.secondary]), startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                    Text("ANALYZING VIBE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            
            Text("CALIBRATING DIGITAL NEURONS...")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(NeonCouture.secondary)
            
            Spacer()
        }
    }
}

struct RadarResultsView: View {
    let dismiss: () -> Void
    
    // Real items to link to
    let recItems = [
        FashionItem(title: "Neon Pulse", subtitle: "2026 Couture Collection", imageName: "Neon Pulse", description: "A high-intensity showcase of bioluminescent fabrics and reactive structural elements that pulse in sync with the wearer's biometric data."),
        FashionItem(title: "Cyber Bloom", subtitle: "Synthetic Organics", imageName: "Cyber Bloom", description: "3D-printed organic shapes that mimic the growth of deep-sea flora, using synthetic biological polymers."),
        FashionItem(title: "Void Silk", subtitle: "Obsidian Aesthetics", imageName: "Void Silk", description: "Crafted from materials that absorb 99% of visible light, accented by razor-thin cyan fiber optics.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(NeonCouture.accent)
                            .neonGlow(color: NeonCouture.accent)
                        
                        Text("MATCH FOUND")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(NeonCouture.primary)
                        
                        Text("NEON VIBE DETECTED")
                            .font(.system(size: 28, weight: .black, design: .serif))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    Text("Based on your neural responses, the following Candyr pieces harmonize perfectly with your current digital energy.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Recommended Items with NavigationLinks
                    VStack(spacing: 16) {
                        ForEach(recItems) { item in
                            if #available(iOS 14.0, *) {
                                NavigationLink(destination: FashionDetailView(item: item)) {
                                    RecommendationRow(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: dismiss) {
                        Text("EXIT RADAR")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(NeonCouture.primary)
                                    .shadow(radius: 5)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .background(NeonCouture.background)
        }
    }
}

struct RecommendationRow: View {
    let item: FashionItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(NeonCouture.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
