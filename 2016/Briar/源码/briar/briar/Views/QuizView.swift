import SwiftUI

struct QuizView: View {
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showResult = false
    
    let questions = [
        "What is your go-to weekend look?",
        "Choose a preferred color palette:",
        "How much time do you spend getting ready?"
    ]
    
    let answers = [
        ["Natural and glowing", "Bold and dramatic", "Quick and simple"],
        ["Soft pinks & neutrals", "Deep reds & darks", "Whatever is clean"],
        ["Over an hour", "About 30 mins", "5 minutes max"]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if showResult {
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)
                        Text("Your Beauty Personality:")
                            .font(.title)
                        Text(resultText)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            currentQuestion = 0
                            score = 0
                            showResult = false
                        }) {
                            Text("Retake Quiz")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Question \(currentQuestion + 1) of \(questions.count)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(questions[currentQuestion])
                            .font(.title)
                            .fontWeight(.bold)
                        
                        ForEach(0..<answers[currentQuestion].count, id: \.self) { index in
                            Button(action: { answerTapped(index: index) }) {
                                Text(answers[currentQuestion][index])
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .foregroundColor(.primary)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Beauty Quiz", displayMode: .inline)
        }
    }
    
    var resultText: String {
        if score <= 2 { return "Effortless Naturalist\nSkincare is your best friend!" }
        if score <= 5 { return "Glam Queen\nYou love a full, dramatic makeup beat!" }
        return "Quick & Chic\nPractical styling is your ultimate go-to."
    }
    
    func answerTapped(index: Int) {
        score += index
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
        } else {
            showResult = true
        }
    }
}
