import SwiftUI

@available(iOS 14.0, *)
struct DancePulseView: View {
    @State private var animateChart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("DANCE PULSE")
                    .font(.system(size: 14, weight: .black))
                    .tracking(2)
                    .foregroundColor(.blue)
                
                Text("Your practice momentum & trend analysis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Chart Area
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    .frame(height: 200)
                
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<7, id: \.self) { day in
                        BarView(index: day, animate: animateChart)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
            
            // Stats Grid
            HStack(spacing: 15) {
                StatCard(icon: "flame.fill", label: "Streak", value: "12 Days", color: .orange)
                StatCard(icon: "bolt.fill", label: "Velocity", value: "8.4 km/h", color: .blue)
            }
            .padding(.horizontal)
            
            // Analysis Text
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                
                Text("You're maintaining a high consistency in Contemporary moves. Consider adding more Ballet segments to improve flexibility scores.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animateChart = true
            }
        }
    }
}

@available(iOS 14.0, *)
struct BarView: View {
    let index: Int
    let animate: Bool
    
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let values: [CGFloat] = [0.4, 0.7, 0.5, 0.9, 0.3, 0.8, 0.6]
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 30, height: 160)
                
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.5), .blue]), startPoint: .top, endPoint: .bottom))
                    .frame(width: 30, height: animate ? 160 * values[index] : 0)
            }
            
            Text(days[index])
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
}

@available(iOS 14.0, *)
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .cornerRadius(16)
    }
}
