import SwiftUI

struct Line {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

struct ScratchpadView: View {
    @State private var lines: [Line] = []
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 5
    
    let colors: [Color] = [.black, .gray, .red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Toolbar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .shadow(radius: 2)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        Button(action: {
                            lines.removeAll()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.secondarySystemBackground))
                
                // Canvas Area
                GeometryReader { geometry in
                    ZStack {
                        Color(UIColor.systemBackground)
                            .edgesIgnoringSafeArea(.all)
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { value in
                                        let newPoint = value.location
                                        if value.translation.width == 0 && value.translation.height == 0 {
                                            // Start of a new line
                                            lines.append(Line(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                                        } else {
                                            // Append to the last line
                                            guard let lastIdx = lines.indices.last else { return }
                                            lines[lastIdx].points.append(newPoint)
                                        }
                                    }
                            )
                        
                        ForEach(lines.indices, id: \.self) { index in
                            let line = lines[index]
                            Path { path in
                                guard let firstPoint = line.points.first else { return }
                                path.move(to: firstPoint)
                                for i in 1..<line.points.count {
                                    path.addLine(to: line.points[i])
                                }
                            }
                            .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                        }
                    }
                }
            }
            .navigationBarTitle("Idea Scratchpad", displayMode: .inline)
        }
    }
}

struct ScratchpadView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchpadView()
    }
}
