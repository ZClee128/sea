import SwiftUI

// MARK: - Main Tab Container
@available(iOS 15.0, *)
struct MainTabView: View {
    @State private var selectedTab: Int = 0

    init() {
        // 彻底透明化 iOS 15 系统自带的原生 TabBar，防止原生 UI 干扰
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── 原生内容容器（利用 Apple 原生底层路由，确保点击绝对生效） ──
            TabView(selection: $selectedTab) {
                ExploreView()
                    .tag(0)
                VideosView()
                    .tag(1)
                FavoritesView()
                    .tag(2)
                ProgramsView()
                    .tag(3)
                SettingsView()
                    .tag(4)
            }
            
            // ── 完全独立的自定义悬浮 TabBar ──
            CustomTabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar View
@available(iOS 15.0, *)
struct CustomTabBarView: View {
    @Binding var selectedTab: Int

    private let tabIcons  = ["flame.fill", "leaf.fill", "heart.fill", "list.bullet.clipboard", "gearshape.fill"]
    private let tabLabels = ["Explore", "Wellness", "Favorites", "Programs", "Settings"]

    var body: some View {
        VStack(spacing: 0) {
            // 顶部边线
            Rectangle()
                .fill(Color(hex: "#F0E0E5"))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { i in
                    Button {
                        selectedTab = i // 更新状态
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                // 粉色高亮背景底框
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedTab == i ? Color(hex: "#E8517A").opacity(0.12) : Color.clear)
                                    .frame(width: 44, height: 28)

                                // 图标
                                Image(systemName: tabIcons[i])
                                    .font(.system(size: selectedTab == i ? 20 : 18,
                                                  weight: selectedTab == i ? .semibold : .regular))
                                    .foregroundColor(selectedTab == i ? Color(hex: "#E8517A") : Color(hex: "#7A7A9D"))
                            }

                            // 文字
                            Text(tabLabels[i])
                                .font(.system(size: 10, weight: selectedTab == i ? .semibold : .regular))
                                .foregroundColor(selectedTab == i ? Color(hex: "#E8517A") : Color(hex: "#7A7A9D"))
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle()) // 使按钮完全可点击
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 10) // 基础内边距即可，安全区由下面的 ignoresSafeArea 自动处理
        }
        .background(
            ZStack {
                BlurView(style: .systemUltraThinMaterial)
                Color.white.opacity(0.85) // 防穿透毛玻璃
            }
            .ignoresSafeArea(edges: .bottom) // 核心修复：让背景自动延伸覆盖底部安全区，防止原生 TabBar 漏出或重绘漂移
        )
    }
}

// MARK: - Blur view wrapper
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
