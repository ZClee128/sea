import SwiftUI

@available(iOS 14.0, *)
struct LightingBlueprintView: View {
    let lightingType: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var keyOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isPulsing = false
    @State private var hasInitialized = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Grid Background
            if #available(iOS 15.0, *) {
                Canvas { context, size in
                    let step: CGFloat = 30
                    for x in stride(from: 0, through: size.width, by: step) {
                        context.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) }, with: .color(Color.white.opacity(0.05)), lineWidth: 0.5)
                    }
                    for y in stride(from: 0, through: size.height, by: step) {
                        context.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) }, with: .color(Color.white.opacity(0.05)), lineWidth: 0.5)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                // Fallback on earlier versions
            }
            
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(lightingType) Setup")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            Text("Professional Lighting Blueprint")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Technical Diagram
                    ZStack {
                        // Subject
                        VStack(spacing: 4) {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 50, height: 50)
                                .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                            Text("SUBJECT").font(.system(size: 8, weight: .bold)).foregroundColor(.gray)
                        }
                        
                        // Path lines
                        Path { p in
                            p.move(to: CGPoint(x: geo.size.width/2 + keyOffset.width, y: geo.size.height/2 + keyOffset.height))
                            p.addLine(to: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.yellow.opacity(0.3))

                        // Key Light (Draggable)
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(isPulsing ? 0.3 : 0.1))
                                    .frame(width: 44, height: 44)
                                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                                
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                            }
                            Text("KEY").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                        }
                        .offset(keyOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newWidth = lastOffset.width + value.translation.width
                                    let newHeight = lastOffset.height + value.translation.height
                                    
                                    let limitW = geo.size.width / 2 - 30
                                    let limitH = geo.size.height / 2 - 100
                                    
                                    keyOffset = CGSize(
                                        width: max(-limitW, min(limitW, newWidth)),
                                        height: max(-limitH, min(limitH, newHeight))
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = keyOffset
                                }
                        )
                        
                        // Camera
                        VStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.blue)
                            Text("CAM").font(.system(size: 8, weight: .bold)).foregroundColor(.white)
                        }
                        .offset(y: 150)
                    }
                    
                    Spacer()
                    
                    // Specs
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Technical Specifications").font(.subheadline).bold().foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            SpecItem(label: "Key Distance", value: String(format: "%.1fm", sqrt(pow(keyOffset.width/40, 2) + pow(keyOffset.height/40, 2))))
                            SpecItem(label: "Modifier", value: getModifier())
                            SpecItem(label: "Intensity", value: getIntensity())
                        }
                        
                        Text(getInstructions())
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            initializeSetup()
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func initializeSetup() {
        guard !hasInitialized else { return }
        switch lightingType.lowercased() {
        case let t where t.contains("rembrandt"):
            keyOffset = CGSize(width: 80, height: -80)
        case let t where t.contains("butterfly"):
            keyOffset = CGSize(width: 0, height: -120)
        case let t where t.contains("split"):
            keyOffset = CGSize(width: 120, height: 0)
        case let t where t.contains("loop"):
            keyOffset = CGSize(width: 60, height: -60)
        case let t where t.contains("rim"):
            keyOffset = CGSize(width: 100, height: 100)
        default:
            keyOffset = CGSize(width: 80, height: -80)
        }
        lastOffset = keyOffset
        hasInitialized = true
    }
    
    func getModifier() -> String {
        switch lightingType.lowercased() {
        case let t where t.contains("butterfly"): return "Beauty Dish"
        case let t where t.contains("rim"): return "Strip Box"
        default: return "Octabox 90"
        }
    }
    
    func getIntensity() -> String {
        switch lightingType.lowercased() {
        case let t where t.contains("rim"): return "f/11"
        default: return "f/8.0"
        }
    }
    
    func getInstructions() -> String {
        switch lightingType.lowercased() {
        case let t where t.contains("rembrandt"): return "Place light 45° to the side and slightly above head height to create the signature triangle shadow."
        case let t where t.contains("butterfly"): return "Position light directly in front and above the subject's face to create a butterfly-shaped shadow under the nose."
        case let t where t.contains("split"): return "Place light exactly at a 90° angle to the subject to illuminate only one half of the face."
        case let t where t.contains("loop"): return "A subtle variation of Rembrandt; position light slightly lower and more towards the camera."
        case let t where t.contains("rim"): return "Place light behind the subject to create a highlight along the edges of the hair and shoulders."
        default: return "Follow the interactive diagram to set up your studio lighting."
        }
    }
}

@available(iOS 14.0, *)
struct SpecItem: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.system(size: 10)).foregroundColor(.gray)
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
        }
    }
}
