import SwiftUI

@available(iOS 14.0, *)
struct MainTabView: View {
    @State private var selectedTab: Tab = .editorial
    
    enum Tab: String, CaseIterable {
        case editorial = "book.closed"
        case planner = "figure.walk" // Changed from wand.and.stars
        case tutorials = "play.tv"
        case moodBoard = "square.grid.2x2"
        case settings = "gearshape"
        
        var title: String {
            switch self {
            case .editorial: return "Editorial"
            case .planner: return "Pose Lab" // Changed from AI Planner
            case .tutorials: return "Tutorials"
            case .moodBoard: return "Board"
            case .settings: return "Settings"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content Layer
            Group {
                switch selectedTab {
                case .editorial:
                    EditorialFeedView()
                case .planner:
                    PoseLabView()
                case .tutorials:
                    TutorialsFeedView()
                case .moodBoard:
                    MoodBoardView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tab Bar Layer
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: tab.rawValue)
                                    .font(.system(size: 20, weight: selectedTab == tab ? .bold : .medium))
                                    .foregroundColor(selectedTab == tab ? DesignTokens.Colors.accent : Color(hex: "999999"))
                                
                                Text(tab.title)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(selectedTab == tab ? DesignTokens.Colors.accent : Color(hex: "999999"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .padding(.horizontal, 10)
                .background(
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight) // Light material
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            .allowsHitTesting(true)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(DesignTokens.Colors.background.ignoresSafeArea())
    }
}

@available(iOS 14.0, *)
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
