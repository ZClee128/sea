import SwiftUI

struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
}

@available(iOS 14.0, *)
struct HairDNAProfiler: View {
    @State private var currentStep = 0
    @State private var answers: [Int] = []
    @State private var showResult = false
    
    let questions = [
        QuizQuestion(text: "Essential DNA Marker 1: Hair Texture", options: ["Fine", "Medium", "Coarse", "Synthetic"]),
        QuizQuestion(text: "What is your primary hair concern?", options: ["Add Volume", "Reduce Frizz", "Damage Repair", "Dandruff Control"]),
        QuizQuestion(text: "Environmental Exposure Level", options: ["High UV", "Humid", "Dry/Cold", "Normal"])
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if !showResult {
                    quizBody
                } else {
                    resultBody
                }
            }
            .navigationBarTitle("Hair DNA Profiling")
            .background(AppTheme.background.edgesIgnoringSafeArea(.all))
        }
    }
    
    private var quizBody: some View {
        VStack(spacing: 30) {
            // Curated Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("SEQUENCE PROGRESS: \(Int(CGFloat(currentStep + 1) / CGFloat(questions.count) * 100))%")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(AppTheme.primary)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.primary)
                        .frame(width: CGFloat(currentStep + 1) / CGFloat(questions.count) * (UIScreen.main.bounds.width - 40), height: 6)
                }
            }
            .padding()
            
            Text(questions[currentStep].text)
                .font(AppTheme.titleSemiBold(size: 24))
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 15) {
                ForEach(0..<questions[currentStep].options.count, id: \.self) { index in
                    Button(action: {
                        answers.append(index)
                        if currentStep < questions.count - 1 {
                            currentStep += 1
                        } else {
                            showResult = true
                        }
                    }) {
                        Text(questions[currentStep].options[index])
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
    }
    
    private var resultBody: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image(systemName: "dna")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.primary)
                    .padding()
                
                Text("Identity Profile Generated")
                    .font(AppTheme.titleSemiBold(size: 24))
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("DNA Analysis Results:")
                        .font(.headline)
                    
                    Text("Your hair sequence indicates a need for deep structural hydration. We have curated specific care protocols tailored to your unique profile.")
                        .font(AppTheme.bodyRegular(size: 16))
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    Text("Junip Curated Protocol:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TipItem(text: "Molecular-level repair mask weekly.")
                        TipItem(text: "Apply serum before thermogenic styling.")
                        TipItem(text: "Avoid high-alkaline shampoos.")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding()
                
                Button(action: {
                    currentStep = 0
                    answers = []
                    showResult = false
                }) {
                    Text("RE-SEQUENCE DNA")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.secondary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

@available(iOS 14.0, *)
struct TipItem: View {
    let text: String
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(AppTheme.primary)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.text)
        }
    }
}
