import SwiftUI

struct QuizQuestion {
    let text: String
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let points: Int
}

struct ProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: geometry.size.width, height: 8)
                    .foregroundColor(Color(UIColor.tertiarySystemGroupedBackground))
                
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: min(progress * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(.black)
                    .animation(.linear(duration: 0.3))
            }
        }
        .frame(height: 8)
    }
}

struct QuizView: View {
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var selectedOptionId: UUID? = nil
    
    let questions: [QuizQuestion] = [
        QuizQuestion(text: "What is your go-to weekend look?", options: [
            QuizOption(text: "Natural and glowing", icon: "sparkles", points: 0),
            QuizOption(text: "Bold and dramatic", icon: "flame.fill", points: 2),
            QuizOption(text: "Quick and simple", icon: "clock.fill", points: 1)
        ]),
        QuizQuestion(text: "Choose your color palette:", options: [
            QuizOption(text: "Soft pinks & neutrals", icon: "drop.fill", points: 0),
            QuizOption(text: "Deep reds & darks", icon: "heart.fill", points: 2),
            QuizOption(text: "Whatever is clean", icon: "leaf.fill", points: 1)
        ]),
        QuizQuestion(text: "How much time do you have?", options: [
            QuizOption(text: "Over an hour", icon: "hourglass", points: 2),
            QuizOption(text: "About 30 mins", icon: "timer", points: 1),
            QuizOption(text: "5 minutes max", icon: "bolt.fill", points: 0)
        ]),
        QuizQuestion(text: "Favorite skincare step?", options: [
            QuizOption(text: "Hydrating Serums", icon: "wand.and.stars", points: 0),
            QuizOption(text: "Heavy Moisturizers", icon: "moon.stars.fill", points: 2),
            QuizOption(text: "Splash of water", icon: "drop", points: 1)
        ]),
        QuizQuestion(text: "Must-have product?", options: [
            QuizOption(text: "Sunscreen", icon: "sun.max.fill", points: 0),
            QuizOption(text: "Red Lipstick", icon: "mouth.fill", points: 2),
            QuizOption(text: "Just Lip Balm", icon: "smiley", points: 1)
        ])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if showResult {
                    resultScreen
                        .transition(.scale)
                } else {
                    quizScreen
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .navigationBarTitle("Beauty Profile", displayMode: .inline)
        }
    }
    
    var quizScreen: some View {
        VStack(spacing: 24) {
            // Progress Header
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(currentQuestion + 1)")
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(currentQuestion + 1)/\(questions.count)")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
                
                ProgressBar(progress: CGFloat(currentQuestion + 1) / CGFloat(questions.count))
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Text(questions[currentQuestion].text)
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(questions[currentQuestion].options) { option in
                    Button(action: {
                        withAnimation {
                            selectedOptionId = option.id
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            answerTapped(points: option.points)
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: option.icon)
                                .font(.system(size: 22))
                                .foregroundColor(selectedOptionId == option.id ? .white : .black)
                                .frame(width: 35)
                            
                            Text(option.text)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            
                            if selectedOptionId == option.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(selectedOptionId == option.id ? Color.black : Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                        .foregroundColor(selectedOptionId == option.id ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var resultText: String {
        if score <= 4 { return "Effortless Naturalist" }
        if score <= 8 { return "Chic & Practical" }
        return "Glam Queen"
    }
    
    var resultDescription: String {
        if score <= 4 { return "Skincare is your best friend. You prefer letting your natural beauty shine through without a heavy routine." }
        if score <= 8 { return "You know exactly how to balance a gorgeous look with a busy schedule. Efficient and stylish!" }
        return "You love a full dramatic beat and aren't afraid of trying out bold, show-stopping new trends."
    }
    
    var recommendedPosts: [Post] {
        if score <= 4 { return posts.filter { $0.category == .skincare || $0.category == .news } }
        if score <= 8 { return posts.filter { $0.category == .styling || $0.category == .skincare } }
        return posts.filter { $0.category == .makeup || $0.category == .styling }
    }
    
    var resultScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 10)
                
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.05))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.black)
                }
                
                VStack(spacing: 12) {
                    Text("Your Style Is".uppercased())
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text(resultText)
                        .font(.system(size: 30, weight: .black))
                        .multilineTextAlignment(.center)
                    
                    Text(resultDescription)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommended For You")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    ForEach(recommendedPosts) { post in
                        PostCard(post: post)
                            .padding(.bottom, 8)
                    }
                }
                
                Button(action: {
                    withAnimation {
                        currentQuestion = 0
                        score = 0
                        selectedOptionId = nil
                        showResult = false
                    }
                }) {
                    Text("Retake Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
            }
        }
    }
    
    func answerTapped(points: Int) {
        score += points
        withAnimation {
            if currentQuestion < questions.count - 1 {
                currentQuestion += 1
                selectedOptionId = nil
            } else {
                showResult = true
            }
        }
    }
}
