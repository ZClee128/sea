import SwiftUI

struct QuizView: View {
    @ObservedObject var appState: AppState
    var onComplete: (() -> Void)? = nil
    
    @State private var currentQuestionIndex = 0
    @State private var showingResult = false
    
    let questions = [
        "What is the shape of your jawline?",
        "How would you describe your cheekbones?",
        "What is your primary hair concern?"
    ]
    
    let options = [
        ["Soft and rounded", "Strong and square", "Pointy and sharp"],
        ["Prominent", "Subtle", "High"],
        ["Volume", "Frizz control", "Styling ideas"]
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                if showingResult {
                    ResultView(appState: appState, onComplete: onComplete)
                } else {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if #available(iOS 14.0, *) {
                            Text(questions[currentQuestionIndex])
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        VStack(spacing: 15) {
                            ForEach(options[currentQuestionIndex], id: \.self) { option in
                                Button(action: {
                                    handleAnswer()
                                }) {
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handleAnswer() {
        withAnimation {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
            } else {
                showingResult = true
            }
        }
    }
}

struct ResultView: View {
    @ObservedObject var appState: AppState
    var onComplete: (() -> Void)? = nil
    
    @State private var isAnalyzing = true
    
    var body: some View {
        VStack(spacing: 20) {
            if isAnalyzing {
                if #available(iOS 14.0, *) {
                    ProgressView("Analyzing your profile...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isAnalyzing = false
                                }
                            }
                        }
                } else {
                    // Fallback on earlier versions
                }
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                
                Text("Your Profile is Ready!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We've tailored the lookbook recommendations based on your face shape and preferences.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
                
                Button(action: {
                    withAnimation {
                        if let onComplete = onComplete {
                            onComplete()
                        } else {
                            appState.hasCompletedQuiz = true
                        }
                    }
                }) {
                    Text(onComplete != nil ? "Save Profile & Close" : "Explore Lookbook")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
            }
        }
        .padding()
    }
}
