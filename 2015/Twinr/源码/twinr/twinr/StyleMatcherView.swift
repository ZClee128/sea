import SwiftUI

@available(iOS 14.0, *)
struct StyleMatcherView: View {
    @State private var isQuizActive = false
    @State private var currentStep = 0
    @State private var selectedOccasion = "Daily"
    @State private var selectedMood = "Minimalist"
    @State private var selectedShape = "Almond"
    @State private var selectedTone = "Warm"
    
    @State private var recommendation: NailDesign?
    @State private var isMatching = false
    
    @ObservedObject var historyManager = MatchHistoryManager.shared
    
    let occasions = ["Daily", "Wedding", "Party", "Work"]
    let moods = ["Minimalist", "Bold", "Sparkly", "Classic"]
    let shapes = ["Almond", "Square", "Oval", "Stiletto"]
    let tones = ["Warm", "Cool", "Neutral", "Pastel"]
    
    var body: some View {
        NavigationView {
            VStack {
                if !isQuizActive {
                    WelcomeView(isQuizActive: $isQuizActive, history: historyManager.history)
                } else {
                    QuizFlowView(
                        currentStep: $currentStep,
                        selectedOccasion: $selectedOccasion,
                        selectedMood: $selectedMood,
                        selectedShape: $selectedShape,
                        selectedTone: $selectedTone,
                        isMatching: $isMatching,
                        onComplete: { generateMatch() },
                        onCancel: { isQuizActive = false; currentStep = 0 }
                    )
                }
            }
            .navigationTitle(isQuizActive ? "Consultation" : "Style Matcher")
            .sheet(item: $recommendation) { design in
                RecommendationResultView(design: design, onDismiss: {
                    isQuizActive = false
                    currentStep = 0
                })
            }
        }
    }
    
    func generateMatch() {
        withAnimation { isMatching = true }
        
        // Simulate complex analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let result = getRecommendation()
            self.recommendation = result
            historyManager.saveMatch(design: result, occasion: selectedOccasion, mood: selectedMood)
            isMatching = false
        }
    }
    
    func getRecommendation() -> NailDesign {
        // Advanced mapping logic using all 4 dimensions
        switch (selectedOccasion, selectedMood, selectedShape, selectedTone) {
        case ("Wedding", _, _, "Pastel"):
            return NailDesign(name: "Bridal White", category: "Wedding", imageName: "Bridal White", description: "Elegant white nails with soft pastel undertones for your special day.", isTrending: true)
        case ("Party", "Bold", "Stiletto", _):
            return NailDesign(name: "Midnight Blue", category: "Modern", imageName: "Midnight Blue", description: "Deep blue with sharp stiletto shaping for a bold statement.", isTrending: true)
        case ("Party", "Sparkly", _, "Warm"):
            return NailDesign(name: "Golden Leaf", category: "Artistic", imageName: "Golden Leaf", description: "Warm golden leaves that sparkle under party lights.", isTrending: true, isPremium: true, price: 15)
        case ("Daily", "Minimalist", "Almond", "Neutral"):
            return NailDesign(name: "Minimalist Pink", category: "Daily", imageName: "Minimalist Pink", description: "The perfect neutral almond look for everyday chic.", isTrending: false)
        case ("Work", "Classic", "Square", "Cool"):
            return NailDesign(name: "Lavender Mist", category: "Spring", imageName: "Lavender Mist", description: "Cool lavender tones in a professional square shape.", isTrending: false)
        case ("Daily", "Bold", _, _):
            return NailDesign(name: "Chrome Silver", category: "Futuristic", imageName: "Chrome Silver", description: "Stand out every day with high-shine futuristic chrome.", isTrending: false, isPremium: true, price: 10)
        case (_, "Sparkly", _, _):
            return NailDesign(name: "Crystal Quartz", category: "Artistic", imageName: "Crystal Quartz", description: "Iridescent flakes that catch the light from every angle.", isTrending: false)
        default:
            return NailDesign(name: "Forest Green", category: "Nature", imageName: "Forest Green", description: "A balanced, nature-inspired look for any occasion.", isTrending: false)
        }
    }
}

@available(iOS 14.0, *)
struct WelcomeView: View {
    @Binding var isQuizActive: Bool
    let history: [MatchHistoryItem]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Professional Consultation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Let our experts find the perfect nail art based on your unique style, occasion, and preferences.")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Button(action: {
                    withAnimation { isQuizActive = true }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Start Style Quiz")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Matches")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        ForEach(history) { item in
                            HStack(spacing: 15) {
                                Image(item.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.designName)
                                        .font(.headline)
                                    Text("\(item.occasion) • \(item.mood)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(item.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .padding(.vertical)
        }
    }
}

@available(iOS 14.0, *)
struct QuizFlowView: View {
    @Binding var currentStep: Int
    @Binding var selectedOccasion: String
    @Binding var selectedMood: String
    @Binding var selectedShape: String
    @Binding var selectedTone: String
    @Binding var isMatching: Bool
    
    var onComplete: () -> Void
    var onCancel: () -> Void
    
    var progress: Double {
        Double(currentStep + 1) / 4.0
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .accentColor(.pink)
                Text("Step \(currentStep + 1) of 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ZStack {
                if isMatching {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing your preferences...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                } else {
                    switch currentStep {
                    case 0:
                        QuestionCard(title: "What's the occasion?", options: ["Daily", "Wedding", "Party", "Work"], selection: $selectedOccasion)
                    case 1:
                        QuestionCard(title: "What's your current mood?", options: ["Minimalist", "Bold", "Sparkly", "Classic"], selection: $selectedMood)
                    case 2:
                        QuestionCard(title: "Preferred nail shape?", options: ["Almond", "Square", "Oval", "Stiletto"], selection: $selectedShape)
                    case 3:
                        QuestionCard(title: "Select your color tone", options: ["Warm", "Cool", "Neutral", "Pastel"], selection: $selectedTone)
                    default:
                        EmptyView()
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            if !isMatching {
                HStack(spacing: 20) {
                    Button("Cancel") { onCancel() }
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < 3 {
                            withAnimation { currentStep += 1 }
                        } else {
                            onComplete()
                        }
                    }) {
                        Text(currentStep < 3 ? "Next Question" : "Get Result")
                            .fontWeight(.bold)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
    }
}

@available(iOS 14.0, *)
struct QuestionCard: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(option)
                            .foregroundColor(selection == option ? .white : .primary)
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(selection == option ? Color.pink : Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10, y: 5)
        .padding()
    }
}

@available(iOS 14.0, *)
struct RecommendationResultView: View {
    let design: NailDesign
    var onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Your Dream Design")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Image(design.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text(design.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(design.category)
                    .foregroundColor(.secondary)
            }
            
            Text(design.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                onDismiss()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Got it!")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}
