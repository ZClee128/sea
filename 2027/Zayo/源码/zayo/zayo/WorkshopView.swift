import SwiftUI

struct ExportItem: Identifiable {
    let id = UUID()
    let text: String
}

struct WorkshopView: View {
    @State private var selectedSetup: LightingSetup = ZayoData.lightingSetups[0]
    @State private var exportItem: ExportItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Horizontal Style Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ZayoData.lightingSetups) { setup in
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedSetup = setup
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: setup.icon)
                                        .font(.system(size: 24))
                                    Text(setup.name)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .frame(width: 100, height: 80)
                                .background(selectedSetup.id == setup.id ? Color.black : Color.gray.opacity(0.1))
                                .foregroundColor(selectedSetup.id == setup.id ? .white : .black)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Interactive Lighting Diagram
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Lighting Designer")
                                    .font(.system(size: 22, weight: .bold, design: .serif))
                                Spacer()
                                Text("Interactive Simulator")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            
                            // Visual Studio Floor
                            GeometryReader { geometry in
                                ZStack {
                                    // Studio Floor Grid
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        )
                                    
                                    // Grid Lines
                                    Path { path in
                                        for i in 1...3 {
                                            let x = geometry.size.width * CGFloat(i) / 4
                                            path.move(to: CGPoint(x: x, y: 0))
                                            path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                                            
                                            let y = geometry.size.height * CGFloat(i) / 4
                                            path.move(to: CGPoint(x: 0, y: y))
                                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                                        }
                                    }
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                    
                                    // Subject (Model)
                                    VStack(spacing: 4) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.black)
                                        Text("SUBJECT")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }
                                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)
                                    
                                    // Dynamic Light Sources
                                    ForEach(selectedSetup.lights) { light in
                                        LightSourceNode(light: light)
                                            .position(
                                                x: geometry.size.width * light.x,
                                                y: geometry.size.height * light.y
                                            )
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                            .frame(height: 280)
                            
                            // Descriptive Text
                            Text(selectedSetup.diagramDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.03))
                                .cornerRadius(12)
                        }
                        
                        // Technical Checklist
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Session Checklist")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                            
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(selectedSetup.technicalChecklist, id: \.self) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.black)
                                        Text(item)
                                            .font(.body)
                                            .foregroundColor(.primary.opacity(0.8))
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(16)
                        }
                        
                        // Action Button
                        Button(action: {
                            exportPlan()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Shooting Plan")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitle("Zayo Workshop", displayMode: .inline)
        }
        .sheet(item: $exportItem) { item in
            ShareSheet(activityItems: [item.text])
        }
    }
    
    private func exportPlan() {
        var text = "ZAYO SHOOTING PLAN: \(selectedSetup.name.uppercased())\n\n"
        text += "DESCRIPTION: \(selectedSetup.description)\n\n"
        text += "LIGHTING SETUP:\n\(selectedSetup.diagramDescription)\n\n"
        text += "TECHNICAL CHECKLIST:\n"
        for item in selectedSetup.technicalChecklist {
            text += "- \(item)\n"
        }
        text += "\nGenerated by Zayo."
        
        self.exportItem = ExportItem(text: text)
    }
}

struct LightSourceNode: View {
    let light: LightSource
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
            }
            
            Text(light.type.uppercased())
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black)
                .cornerRadius(4)
        }
    }
}

struct WorkshopView_Previews: PreviewProvider {
    static var previews: some View {
        WorkshopView()
    }
}
