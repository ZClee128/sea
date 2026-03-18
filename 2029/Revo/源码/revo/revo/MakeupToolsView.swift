import SwiftUI

struct MakeupTool: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let usage: String
    let tips: String
    let iconName: String
}

struct MakeupToolsView: View {
    let tools = [
        MakeupTool(name: "Foundation Brush", description: "Large, flat brush for liquid and cream foundations.", usage: "Apply foundation in a circular motion for a buffed finish or downward strokes for full coverage.", tips: "Clean weekly to prevent product buildup and bacteria.", iconName: "paintbrush.fill"),
        MakeupTool(name: "Blending Sponge", description: "Teardrop-shaped sponge for seamless blending.", usage: "Dampen the sponge, squeeze out excess water, and bounce over the skin.", tips: "Use the pointed tip for inner eye corners and the rounded base for cheeks.", iconName: "circle.fill"),
        MakeupTool(name: "Angled Liner Brush", description: "Thin, firm brush with an angled tip for precision.", usage: "Apply gel or powder eyeliner along the lash line.", tips: "Can also be used to fill in eyebrows with hair-like strokes.", iconName: "pencil.tip"),
        MakeupTool(name: "Powder Brush", description: "Large, fluffy brush for setting powders and bronzers.", usage: "Dip in powder, tap off excess, and lightly dust over the face.", tips: "Focus on the T-zone for oil control.", iconName: "sparkles"),
        MakeupTool(name: "Fan Brush", description: "Flat, fan-shaped brush for delicate applications.", usage: "Lightly dust highlighter along the tops of cheekbones.", tips: "Also great for sweeping away eyeshadow fallout.", iconName: "wind"),
        MakeupTool(name: "Crease Brush", description: "Tapered, medium-sized brush for eye definition.", usage: "Apply darker shadow into the crease of the eyelid in a windshield-wiper motion.", tips: "Keep the handle pointed towards your ear for the best angle.", iconName: "eye.fill"),
        MakeupTool(name: "Lip Brush", description: "Small, firm brush with a pointed tip for lips.", usage: "Outline lips first, then fill in with your favorite lipstick.", tips: "Use to clean up lipstick edges with a tiny bit of concealer.", iconName: "pencil"),
        MakeupTool(name: "Kabuki Brush", description: "Short, dense brush with a large surface area.", usage: "Buff mineral foundation or bronzer onto the skin for a high-definition finish.", tips: "Use firm pressure in small circles for the most coverage.", iconName: "circle.grid.2x2.fill")
    ]
    
    @State private var showingColorTheory = false
    @State private var showingQuiz = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Interactive Tools")) {
                    // Color Theory
                    Button(action: { showingColorTheory = true }) {
                        HStack {
                            ZStack {
                                Circle().fill(RevoDesign.premiumGradient)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "circle.grid.cross.fill")
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading) {
                                Text("Color Theory Palette")
                                    .font(.headline)
                                    .foregroundColor(RevoDesign.text)
                                Text("Find your perfect skin tone match.")
                                    .font(.caption)
                                    .foregroundColor(RevoDesign.textSecondary)
                            }
                        }
                    }
                    
                    // Beauty Style Quiz
                    Button(action: { showingQuiz = true }) {
                        HStack {
                            ZStack {
                                Circle().fill(LinearGradient(colors: [Color(hex: "FF6B9D"), Color(hex: "C44569")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading) {
                                Text("Beauty Style Quiz")
                                    .font(.headline)
                                    .foregroundColor(RevoDesign.text)
                                Text("Discover your signature makeup style.")
                                    .font(.caption)
                                    .foregroundColor(RevoDesign.textSecondary)
                            }
                            Spacer()
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(RevoDesign.primary)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Section(header: Text("Brush Encyclopedia")) {
                    ForEach(tools) { tool in
                        NavigationLink(destination: ToolDetailView(tool: tool)) {
                            HStack {
                                Image(systemName: tool.iconName)
                                    .foregroundColor(RevoDesign.primary)
                                    .frame(width: 30)
                                
                                Text(tool.name)
                                    .font(.headline)
                                    .foregroundColor(RevoDesign.text)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationBarTitle("Pro Studio", displayMode: .inline)
            .sheet(isPresented: $showingColorTheory) {
                ColorTheoryView()
            }
            .sheet(isPresented: $showingQuiz) {
                BeautyStyleQuizView()
            }
        }
        .forceLightMode()
    }
}

// MARK: - Beauty Style Quiz
struct QuizQuestion {
    let text: String
    let options: [String]
}

struct BeautyStyleQuizView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentQuestion = 0
    @State private var answers: [Int] = []
    @State private var showResult = false
    
    let questions = [
        QuizQuestion(
            text: "What's your go-to weekend vibe?",
            options: ["Brunch with friends — effortlessly chic", "Hiking in nature — bare-faced and free", "Art gallery visit — bold and expressive", "Movie night in — comfortable and cozy"]
        ),
        QuizQuestion(
            text: "Pick your ideal lip color:",
            options: ["A classic MLBB (My Lips But Better) nude", "Clear gloss — shine only!", "Deep berry or dark plum", "Bright coral or classic red"]
        ),
        QuizQuestion(
            text: "Your everyday skincare finish is:",
            options: ["Dewy and glowing — glass skin goals", "Matte and clean — barely-there look", "Whatever is quick!", "Depends on my mood"]
        ),
        QuizQuestion(
            text: "When you look in the mirror, you want to feel:",
            options: ["Polished and professional", "Natural and effortless", "Artistic and unique", "Glamorous and bold"]
        ),
        QuizQuestion(
            text: "Your makeup bag essential is:",
            options: ["A good concealer — skin first always", "Mascara — quick and effective", "An eyeshadow palette — endless creativity", "Statement lipstick — it says everything"]
        )
    ]
    
    private var result: (title: String, description: String, icon: String) {
        // Tally scores: 0=Classic, 1=Natural, 2=Artistic, 3=Glam
        var scores = [0, 0, 0, 0]
        for answer in answers {
            if answer < 4 { scores[answer] += 1 }
        }
        let topIndex = scores.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0
        switch topIndex {
        case 0: return ("Classic Chic ✨", "You gravitate toward timeless, polished looks. Think clean skin, defined brows, a nude lip, and the perfect mascara. You believe less is more—but executed flawlessly.", "crown.fill")
        case 1: return ("Natural Glow 🌿", "Your style is effortless and skin-forward. You love enhancing your natural beauty with tinted moisturizers, groomed brows, and a fresh-faced flush. Dewy skin is your signature.", "leaf.fill")
        case 2: return ("Artistic Spirit 🎨", "Makeup is your canvas. You love experimenting with bold colors, graphic liner, and unexpected combinations. Trends are just a starting point—your look is always uniquely yours.", "paintpalette.fill")
        default: return ("Glam Goddess 💄", "You live for a full glam moment. Lashes, contour, highlight, and a statement lip are your essentials. You see every day as an occasion worth dressing up for.", "sparkles")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showResult {
                    // Result View
                    ScrollView {
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .fill(RevoDesign.premiumGradient)
                                    .frame(width: 120, height: 120)
                                Image(systemName: result.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 30)
                            
                            Text("Your Style is…")
                                .font(.subheadline)
                                .foregroundColor(RevoDesign.textSecondary)
                            
                            Text(result.title)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(RevoDesign.text)
                                .multilineTextAlignment(.center)
                            
                            Text(result.description)
                                .font(.body)
                                .foregroundColor(RevoDesign.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .lineSpacing(5)
                            
                            Button(action: {
                                currentQuestion = 0
                                answers = []
                                showResult = false
                            }) {
                                Text("Retake Quiz")
                                    .font(.subheadline.bold())
                                    .foregroundColor(RevoDesign.primary)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(RevoDesign.primary, lineWidth: 1.5)
                                    )
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                    }
                } else {
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(RevoDesign.secondary)
                                .frame(height: 4)
                            Rectangle()
                                .fill(RevoDesign.primary)
                                .frame(width: geo.size.width * CGFloat(currentQuestion) / CGFloat(questions.count), height: 4)
                                .animation(.easeInOut, value: currentQuestion)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Question \(currentQuestion + 1) of \(questions.count)")
                                .font(.caption)
                                .foregroundColor(RevoDesign.textSecondary)
                                .padding(.top, 20)
                            
                            Text(questions[currentQuestion].text)
                                .font(.headline)
                                .bold()
                                .foregroundColor(RevoDesign.text)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 12) {
                                ForEach(0..<questions[currentQuestion].options.count, id: \.self) { i in
                                    Button(action: {
                                        answers.append(i)
                                        if currentQuestion < questions.count - 1 {
                                            withAnimation { currentQuestion += 1 }
                                        } else {
                                            withAnimation { showResult = true }
                                        }
                                    }) {
                                        HStack {
                                            Text(questions[currentQuestion].options[i])
                                                .font(.subheadline)
                                                .foregroundColor(RevoDesign.text)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(RevoDesign.primary)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(RevoDesign.secondary.opacity(0.5))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(RevoDesign.primary.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitle("Beauty Style Quiz", displayMode: .inline)
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .forceLightMode()
    }
}

// MARK: - Tool Detail View
struct ToolDetailView: View {
    let tool: MakeupTool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(RevoDesign.secondary)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: tool.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(RevoDesign.primary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(tool.name)
                            .font(.largeTitle)
                            .bold()
                        Text("Professional Grade")
                            .font(.subheadline)
                            .foregroundColor(RevoDesign.textSecondary)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    InfoBlock(title: "Overview", content: tool.description)
                    InfoBlock(title: "How to Use", content: tool.usage)
                    InfoBlock(title: "Pro Tip", content: tool.tips, highlight: true)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(Text(tool.name), displayMode: .inline)
    }
}

struct InfoBlock: View {
    let title: String
    let content: String
    var highlight: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(highlight ? RevoDesign.primary : RevoDesign.text)
            
            Text(content)
                .font(.body)
                .foregroundColor(RevoDesign.textSecondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(highlight ? RevoDesign.primary.opacity(0.1) : RevoDesign.secondary.opacity(0.3))
                .cornerRadius(10)
        }
    }
}

// MARK: - Color Theory View
struct ColorTheoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTone: Color = Color(white: 0.95)
    @State private var undertone: String = "Cool"
    
    private var matchingShades: [Color] {
        switch undertone {
        case "Cool":
            return [.pink, .purple, .blue, Color(hex: "E0B0FF")]
        case "Neutral":
            return [.orange, .red, .green, .yellow]
        case "Warm":
            if #available(iOS 15.0, *) {
                return [Color(hex: "800000"), Color(hex: "FF8C00"), Color(hex: "FFD700"), .brown]
            } else {
                return [.pink, .orange, .red]
            }
        case "Rich":
            return [Color(hex: "4B0082"), Color(hex: "DC143C"), .gold, Color(hex: "E97451")]
        default:
            return [.pink, .orange, .red]
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Select your skin shade to find your perfect color palette.")
                    .font(.subheadline)
                    .foregroundColor(RevoDesign.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                ZStack {
                    Circle()
                        .fill(selectedTone)
                        .frame(width: 150, height: 150)
                        .shadow(color: selectedTone.opacity(0.5), radius: 20)
                        .animation(.spring())
                    
                    VStack {
                        if #available(iOS 14.0, *) {
                            Text(undertone)
                                .font(.system(.title3, design: .serif))
                                .bold()
                                .foregroundColor(undertone == "Fair" ? .black : .white.opacity(0.8))
                        }
                    }
                }
                
                VStack(spacing: 15) {
                    Text("Undertone Guide")
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    HStack(spacing: 20) {
                        ToneButton(name: "Fair", color: Color(white: 0.95), undertone: "Cool", current: $selectedTone, currentU: $undertone)
                        ToneButton(name: "Medium", color: Color(hex: "D2B48C"), undertone: "Neutral", current: $selectedTone, currentU: $undertone)
                        ToneButton(name: "Tanned", color: Color(hex: "CD853F"), undertone: "Warm", current: $selectedTone, currentU: $undertone)
                        ToneButton(name: "Deep", color: Color(hex: "8B4513"), undertone: "Rich", current: $selectedTone, currentU: $undertone)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Matching Shades")
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    HStack(spacing: 15) {
                        ForEach(matchingShades, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 50, height: 50)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 5)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut)
                    
                    Text("These specialized shades are curated to enhance your specific skin undertone for a natural, luminous finish.")
                        .font(.caption)
                        .italic()
                        .foregroundColor(RevoDesign.textSecondary)
                        .padding(.top, 5)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RevoDesign.secondary.opacity(0.4))
                .cornerRadius(20)
                
                Spacer()
            }
            .navigationBarTitle("Color Theory", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

extension Color {
    static let gold = Color(hex: "FFD700")
}

struct ToneButton: View {
    let name: String
    let color: Color
    let undertone: String
    @Binding var current: Color
    @Binding var currentU: String
    
    var body: some View {
        Button(action: {
            current = color
            currentU = undertone
        }) {
            VStack {
                Circle().fill(color).frame(width: 50, height: 50)
                    .overlay(Circle().stroke(current == color ? RevoDesign.primary : Color.clear, lineWidth: 3))
                Text(name).font(.caption)
            }
        }
    }
}
