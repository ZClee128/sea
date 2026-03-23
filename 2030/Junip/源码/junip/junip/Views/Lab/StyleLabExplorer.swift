import SwiftUI

@available(iOS 14.0, *)
struct StyleLabExplorer: View {
    @State private var selectedBase: String?
    @State private var selectedBooster: String?
    @State private var selectedFinisher: String?
    @State private var isMixing = false
    @State private var showFormula = false
    
    let bases = [
        LabIngredient(name: "Hydra-Silk Base", icon: "drop.fill", desc: "Moisture retention"),
        LabIngredient(name: "Volumize Core", icon: "arrow.up.circle.fill", desc: "Root elevation"),
        LabIngredient(name: "Repair Matrix", icon: "bandage.fill", desc: "Structural integrity")
    ]
    
    let boosters = [
        LabIngredient(name: "Shine Serum", icon: "sparkles", desc: "+30% Gloss"),
        LabIngredient(name: "Heat Guard", icon: "flame.fill", desc: "230°C Protection"),
        LabIngredient(name: "Frizz Control", icon: "wind", desc: "Humidity defense")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if showFormula {
                    formulaResultView
                } else {
                    labInterfaceView
                }
            }
            .navigationBarTitle("Style Lab", displayMode: .inline)
            .background(AppTheme.background.edgesIgnoringSafeArea(.all))
        }
    }
    
    private var labInterfaceView: some View {
        ScrollView {
            VStack(spacing: 30) {
                labHeader
                
                ingredientSection(title: "STEP 1: CHOOSE BASE", items: bases, selection: $selectedBase)
                
                ingredientSection(title: "STEP 2: ADD BOOSTER", items: boosters, selection: $selectedBooster)
                
                mixingStation
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
    
    private var labHeader: some View {
        VStack(spacing: 8) {
            Text("SEQUENCE BUILDER")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(AppTheme.primary)
            
            Text("Mix your professional routine")
                .font(AppTheme.titleSemiBold(size: 24))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    private func ingredientSection(title: String, items: [LabIngredient], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .tracking(2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        IngredientCard(item: item, isSelected: selection.wrappedValue == item.name) {
                            selection.wrappedValue = item.name
                        }
                    }
                }
            }
        }
    }
    
    private var mixingStation: some View {
        VStack(spacing: 20) {
            if isMixing {
                VStack(spacing: 15) {
                    ProgressView()
                        .accentColor(AppTheme.primary)
                    Text("SYNTHESIZING FORMULA...")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
                .frame(height: 100)
            } else {
                Button(action: startMixing) {
                    Text("GENERATE HAIR DNA")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canMix ? AppTheme.secondary : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: canMix ? 5 : 0)
                }
                .disabled(!canMix)
            }
        }
        .padding(.top, 20)
    }
    
    private var formulaResultView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(AppTheme.primary, lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(spacing: 10) {
                Text("FORMULA ID: #JN-2026")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                
                Text("Your Style Sequence")
                    .font(AppTheme.titleSemiBold(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 20) {
                ResultRow(label: "Base Component", value: selectedBase ?? "")
                ResultRow(label: "Booster Infusion", value: selectedBooster ?? "")
                ResultRow(label: "Finishing Agent", value: "Junip Gloss Elixir")
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: { showFormula = false }) {
                Text("REBUILD FORMULA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                    .padding()
            }
        }
    }
    
    private var canMix: Bool {
        selectedBase != nil && selectedBooster != nil
    }
    
    private func startMixing() {
        withAnimation { isMixing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isMixing = false
                showFormula = true
            }
        }
    }
}

struct LabIngredient: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let desc: String
}

struct IngredientCard: View {
    let item: LabIngredient
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppTheme.primary)
                
                VStack(spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isSelected ? .white : AppTheme.secondary)
                    
                    Text(item.desc)
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                }
            }
            .frame(width: 130, height: 120)
            .background(isSelected ? AppTheme.primary : Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.secondary)
            Divider()
        }
    }
}
