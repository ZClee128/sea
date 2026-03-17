import SwiftUI
import Combine

@available(iOS 14.0, *)
struct PosingWorkshopView: View {
    let poses: [PoseWorkshopItem]
    @State private var currentIndex: Int
    @State private var timeRemaining: Double = 10.0
    @State private var isPaused = false
    @Environment(\.presentationMode) var presentationMode
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let poseDuration: Double = 10.0
    
    struct PoseWorkshopItem: Identifiable {
        let id = UUID()
        let title: String
        let image: String
        let tips: String
    }
    
    init(poses: [PoseWorkshopItem], startIndex: Int = 0) {
        self.poses = poses
        self._currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DesignTokens.Colors.primary.ignoresSafeArea()
                
                // Background Image
                Image(poses[currentIndex].image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .opacity(0.8)
                    .blur(radius: isPaused ? 10 : 0)
                    .animation(.easeInOut, value: isPaused)
                
                // Gradient Overlay
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar (Safe Area Aware)
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("POSING WORKSHOP")
                                .font(DesignTokens.Typography.caption(10))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(currentIndex + 1) / \(poses.count)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, max(geometry.safeAreaInsets.top, 20))
                    
                    // Progress Bar
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 4)
                        Capsule()
                            .fill(DesignTokens.Colors.accent)
                            .frame(width: max(0, CGFloat(timeRemaining / poseDuration) * (geometry.size.width - 40)), height: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Pause Indicator
                    if isPaused {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    // Bottom Content (Safe Area Aware)
                    VStack(spacing: 20) {
                        // Description Box
                        VStack(alignment: .leading, spacing: 10) {
                            Text(poses[currentIndex].title.uppercased())
                                .font(DesignTokens.Typography.title(22))
                                .foregroundColor(.white)
                            
                            Text(poses[currentIndex].tips)
                                .font(DesignTokens.Typography.body(14))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(25)
                        .background(
                            VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                                .cornerRadius(25)
                        )
                        .padding(.horizontal, 15)
                        
                        // Controls
                        HStack(spacing: 50) {
                            Button(action: { navigateToPrevious() }) {
                                Image(systemName: "backward.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { isPaused.toggle() }) {
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                                    .padding(18)
                                    .background(Circle().fill(DesignTokens.Colors.accent))
                            }
                            
                            Button(action: { navigateToNext() }) {
                                Image(systemName: "forward.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 20))
                    }
                }
            }
        }
        .statusBar(hidden: true)
        .onReceive(timer) { _ in
            guard !isPaused else { return }
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                navigateToNext()
            }
        }
    }
    
    private func navigateToNext() {
        withAnimation(.spring()) {
            if currentIndex < poses.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
            timeRemaining = poseDuration
        }
    }
    
    private func navigateToPrevious() {
        withAnimation(.spring()) {
            if currentIndex > 0 {
                currentIndex -= 1
            } else {
                currentIndex = poses.count - 1
            }
            timeRemaining = poseDuration
        }
    }
}
