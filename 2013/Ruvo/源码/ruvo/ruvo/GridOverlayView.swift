import SwiftUI

struct GridOverlayView: View {
    var rows: Int
    var columns: Int
    var opacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Draw vertical lines
                for i in 1..<columns {
                    let x = width * CGFloat(i) / CGFloat(columns)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                
                // Draw horizontal lines
                for i in 1..<rows {
                    let y = height * CGFloat(i) / CGFloat(rows)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.black.opacity(opacity), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
