import SwiftUI

struct GRTalentStudioView: View {
    @ObservedObject var store = GRStoreRegistry.shared
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var resultBmi: Double? = nil
    @State private var showPremiumAnalysis = false
    @State private var isScanning = false
    @State private var scanningProgress: Double = 0.0
    @State private var alertMessage = ""
    @State private var activeAlert: GRStudioAlert? = nil

    enum GRStudioAlert: Identifiable {
        case notice(message: String)
        case aiDisclosure
        
        var id: String {
            switch self {
            case .notice: return "notice"
            case .aiDisclosure: return "aiDisclosure"
            }
        }
    }
    
    // Analysis Results
    @State private var commercialScore = 94
    @State private var marketFit = "High Fashion / Editorial"
    @State private var keyStrength = "Strong Facial Symmetry"
    @State private var recommendation = "Focus on Milan and Paris markets for the upcoming SS26 season. Your technical walk is ready for A-list runways."
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading) {
                    Text("STUDIO")
                        .font(.system(size: 38, weight: .black, design: .serif))
                        .tracking(5)
                        .foregroundColor(.black)
                    Text("PROFESSIONAL TOOLS")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        premiumAnalysisSection
                        
                        Divider().background(Color.black.opacity(0.1))
                        
                        converterSection
                        
                        Divider().background(Color.black.opacity(0.1))
                        
                        industryStatsSection
                    }
                    .padding(.horizontal)
                }
            }
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .notice(let message):
                return Alert(title: Text("Notice"), message: Text(message), dismissButton: .default(Text("OK")))
            case .aiDisclosure:
                return Alert(
                    title: Text("AI Analysis Permissions"),
                    message: Text("To provide modeling insights, Glowr uses an AI engine to analyze your portfolio photos. This process is performed locally on your device to protect your privacy. No personal image data is shared with third-party servers. Do you wish to proceed?"),
                    primaryButton: .default(Text("Agree"), action: {
                        UserDefaults.standard.set(true, forKey: "hasAgreedToAIDisclosure")
                        startAnalysis()
                    }),
                    secondaryButton: .cancel(Text("Decline"))
                )
            }
        }
    }
    
    var premiumAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                if #available(iOS 14.0, *) {
                    Text("AI Portfolio Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                } else {
                    // Fallback on earlier versions
                }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.gold)
                    Text("10")
                        .fontWeight(.bold)
                        .foregroundColor(.gold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.gold.opacity(0.1))
                .cornerRadius(10)
            }
            
            Text("Get depth-insights into your portfolio's commercial potential using our advanced AI modeling engine.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if isScanning {
                VStack(spacing: 20) {
                    if #available(iOS 14.0, *) {
                        ProgressView(value: scanningProgress)
                            .accentColor(.gold)
                    } else {
                        // Custom progress bar for iOS 13
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle().frame(height: 4)
                                    .foregroundColor(Color.black.opacity(0.1))
                                Rectangle().frame(width: geo.size.width * CGFloat(scanningProgress), height: 4)
                                    .foregroundColor(.gold)
                            }
                        }
                        .frame(height: 4)
                    }
                    
                    Text(scanningStatus)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.gold)
                }
                .padding()
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)
            } else if showPremiumAnalysis {
                VStack(alignment: .leading, spacing: 15) {
                    GRInsightMetricRow(label: "Commercial Score", value: "\(commercialScore)/100", color: .green)
                    GRInsightMetricRow(label: "Market Fit", value: marketFit, color: .blue)
                    GRInsightMetricRow(label: "Key Strength", value: keyStrength, color: .gold)
                    
                    Text("Recommendation: \(recommendation)")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    Button(action: startAnalysis) {
                        Text("Re-analyze Portfolio")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gold, lineWidth: 1))
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)
            } else {
                Button(action: {
                    if store.spendCoins(10) {
                        checkAIDisclosure()
                    } else {
                        activeAlert = .notice(message: "Not enough coins. Please visit the Store in Settings to recharge.")
                    }
                }) {
                    Text("Unlock Premium Analysis")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    func checkAIDisclosure() {
        if !UserDefaults.standard.bool(forKey: "hasAgreedToAIDisclosure") {
            activeAlert = .aiDisclosure
        } else {
            startAnalysis()
        }
    }
    
    var scanningStatus: String {
        if scanningProgress < 0.3 { return "Scanning facial features..." }
        if scanningProgress < 0.6 { return "Analyzing portfolio composition..." }
        if scanningProgress < 0.9 { return "Comparing with market trends..." }
        return "Finalizing report..."
    }
    
    func startAnalysis() {
        isScanning = true
        scanningProgress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation {
                scanningProgress += 0.03
            }
            
            if scanningProgress >= 1.0 {
                timer.invalidate()
                generateRandomResults()
                withAnimation {
                    isScanning = false
                    showPremiumAnalysis = true
                }
            }
        }
    }
    
    func generateRandomResults() {
        let scores = [88, 91, 94, 96, 98]
        let fits = ["High Fashion / Editorial", "Commercial / Beauty", "Runway / Global", "Catalog / Fitness"]
        let strengths = ["Strong Facial Symmetry", "Versatile Expression", "Professional Posture", "Unique Aesthetic"]
        let recs = [
            "Focus on Milan and Paris markets for the upcoming SS26 season.",
            "Great potential for high-end skincare and beauty campaigns.",
            "Your technical walk is ready for A-list runways in New York.",
            "Consider expanding into the Asian market for commercial growth."
        ]
        
        commercialScore = scores.randomElement() ?? 94
        marketFit = fits.randomElement() ?? "High Fashion"
        keyStrength = strengths.randomElement() ?? "Facial Symmetry"
        recommendation = recs.randomElement() ?? "Focus on international markets."
    }
    
    var converterSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            if #available(iOS 14.0, *) {
                Text("Industry BMI Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            } else {
                // Fallback on earlier versions
            }
            
            VStack(spacing: 15) {
                GRNumericField(placeholder: "Height (cm)", text: $height)
                GRNumericField(placeholder: "Weight (kg)", text: $weight)
                
                Button(action: calculateBmi) {
                    Text("Calculate BMI")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                
                if let bmi = resultBmi {
                    VStack(alignment: .leading, spacing: 5) {
                        if #available(iOS 14.0, *) {
                            Text("Your BMI: \(String(format: "%.1f", bmi))")
                                .font(.title3)
                                .foregroundColor(.black)
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        Text(bmiFeedback(bmi))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Citations & Medical Disclaimer:")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        Text("BMI calculation and feedback are based on World Health Organization (WHO) standard body mass index classifications. This tool is for informational purposes only and does not constitute medical advice.")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        if #available(iOS 14.0, *) {
                            Link("Learn more about WHO BMI standards", destination: URL(string: "https://www.who.int/data/gho/data/themes/topics/topic-details/GHO/body-mass-index")!)
                                .font(.system(size: 9))
                                .foregroundColor(.blue)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    .padding(.top, 5)
                }
            }
        }
    }
    
    var industryStatsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            if #available(iOS 14.0, *) {
                Text("International Size Guide")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            } else {
                // Fallback on earlier versions
            }
            
            HStack(spacing: 15) {
                GRIndustrySizeCard(label: "EU 34", sub: "US 0-2 / UK 6")
                GRIndustrySizeCard(label: "EU 36", sub: "US 4 / UK 8")
            }
            
            HStack(spacing: 15) {
                GRIndustrySizeCard(label: "EU 38", sub: "US 6 / UK 10")
                GRIndustrySizeCard(label: "EU 40", sub: "US 8 / UK 12")
            }
        }
    }
    
    func calculateBmi() {
        guard let h = Double(height), let w = Double(weight), h > 0 else { return }
        let heightInMeters = h / 100.0
        resultBmi = w / (heightInMeters * heightInMeters)
    }
    
    func bmiFeedback(_ bmi: Double) -> String {
        if bmi < 17.5 { return "Common for runway modeling but maintain health." }
        if bmi < 18.5 { return "Underweight (Standard in high fashion)." }
        if bmi < 25 { return "Healthy weight range." }
        return "Above standard industry range."
    }
}

struct GRNumericField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder).foregroundColor(.gray)
            }
            .padding()
            .background(Color.black.opacity(0.05))
            .foregroundColor(.black)
            .cornerRadius(10)
            .keyboardType(.decimalPad)
    }
}

struct GRIndustrySizeCard: View {
    let label: String
    let sub: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            Text(sub)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
    }
}

struct GRInsightMetricRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}
