import SwiftUI

// MARK: - Blur View

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Corner Radius Helpers

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// MARK: - Shared UI Components

struct TagView: View {
    let text: String
    let icon: String
    let color: Color
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13, weight: .bold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

struct PremiumActionButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                Text(text)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(16)
        }
    }
}
