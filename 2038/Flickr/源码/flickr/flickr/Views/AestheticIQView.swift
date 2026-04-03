import SwiftUI

struct AestheticQuizQuestion: Identifiable {
    let id = UUID()
    let title: String
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id = UUID()
    let imageName: String // Using existing muse images or generic
    let persona: AestheticPersona
    let label: String
}

@available(iOS 15.0, *)
struct AestheticIQView: View {
    @StateObject var personaManager = PersonaManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStep = 0
    @State private var scores: [AestheticPersona: Int] = [:]
    @State private var isFinished = false
    @State private var showResult = false
    
    // Curated questions for the quiz using EXCLUSIVE assets
    let questions: [AestheticQuizQuestion] = [
        AestheticQuizQuestion(title: "Which light speaks to your vision?", options: [
            QuizOption(imageName: "minimalist_architecture", persona: .noir, label: "Structural Shadow"),
            QuizOption(imageName: "ethereal_fog_mountains", persona: .ethereal, label: "Misty Stillness")
        ]),
        AestheticQuizQuestion(title: "What represents your core structure?", options: [
            QuizOption(imageName: "neon_noir_city", persona: .vibrant, label: "Cyber Neon"),
            QuizOption(imageName: "abstract_prism_light_lake", persona: .ethereal, label: "Refracted Light")
        ]),
        AestheticQuizQuestion(title: "Which environment inspires your muse?", options: [
            QuizOption(imageName: "retro_film_grain_aesthetic", persona: .vibrant, label: "Vintage Warmth"),
            QuizOption(imageName: "botanical_macro_texture", persona: .naturalString, label: "Organic Detail")
        ])
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if !isFinished {
                if #available(iOS 16.0, *) {
                    quizContent
                        .transition(.asymmetric(insertion: .push(from: .trailing), removal: .move(edge: .leading)))
                } else {
                    // Fallback on earlier versions
                }
            } else {
                resultContent
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
    }
    
    var quizContent: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                Spacer()
                Text("Aesthetic IQ Test")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Spacer()
                // Progress
                Text("\(currentStep + 1)/\(questions.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 44)
            }
            .padding()
            
            Text(questions[currentStep].title)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                ForEach(questions[currentStep].options) { option in
                    Button(action: { selectOption(option) }) {
                        ZStack(alignment: .bottomLeading) {
                            Image(option.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
                                .cornerRadius(20)
                            
                            Text(option.label)
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(20)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var resultContent: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(personaManager.currentPersona.themeColor.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .blur(radius: 20)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(radius: 20)
            }
            
            VStack(spacing: 12) {
                Text("Result Decoded")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(4)
                
                Text(personaManager.currentPersona.rawValue.uppercased())
                    .font(.system(size: 32, weight: .black, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text(personaManager.currentPersona.description)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("UNFOLD YOUR VISION")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private func selectOption(_ option: QuizOption) {
        scores[option.persona, default: 0] += 1
        
        triggerHaptic()
        
        if currentStep < questions.count - 1 {
            withAnimation(.easeInOut) {
                currentStep += 1
            }
        } else {
            personaManager.setPersona(basedOn: scores)
            withAnimation {
                isFinished = true
            }
            triggerHapticSuccess()
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func triggerHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
