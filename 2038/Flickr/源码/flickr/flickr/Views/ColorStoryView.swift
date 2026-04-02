import SwiftUI

@available(iOS 15.0, *)
struct ColorStoryView: View {
    @StateObject var assetManager = AssetManager()
    @State private var selectedMuse: MuseItem?
    @State private var copiedHex: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Circle().fill(Color(.systemGray6)))
                }
                Spacer()
                Text("Color Story Generator")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                Spacer()
                // Invisible spacer for balance
                Circle().fill(Color.clear).frame(width: 44)
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    if let muse = selectedMuse {
                        // Analysis Section
                        VStack(alignment: .leading, spacing: 20) {
                            Image(muse.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                                .shadow(radius: 10)
                            
                            Text("Aesthetic Deconstruction")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                            
                            Text("We have extracted the core DNA of this visual. These colors represent the emotional and structural foundation of the piece.")
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(.secondary)
                            
                            // Palette Display
                            VStack(spacing: 12) {
                                ForEach(muse.colorPalette, id: \.self) { hex in
                                    HStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: hex))
                                            .frame(width: 60, height: 60)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(hex)
                                                .font(.system(.subheadline, design: .monospaced))
                                                .fontWeight(.bold)
                                            Text("Aesthetic Token #\(hex.suffix(3))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            UIPasteboard.general.string = hex
                                            withAnimation { copiedHex = hex }
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation { copiedHex = nil }
                                            }
                                        }) {
                                            Image(systemName: copiedHex == hex ? "checkmark.circle.fill" : "doc.on.doc")
                                                .foregroundColor(copiedHex == hex ? .green : .gray)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6).opacity(0.4))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: { selectedMuse = nil }) {
                            Text("SELECT ANOTHER IMAGE")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    } else {
                        // Selection Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Choose a source to deconstruct")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(assetManager.muses) { muse in
                                    Button(action: {
                                        withAnimation { selectedMuse = muse }
                                    }) {
                                        VStack(alignment: .leading) {
                                            Image(muse.imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: (UIScreen.main.bounds.width - 60) / 2, height: 160)
                                                .clipped()
                                                .cornerRadius(16)
                                            
                                            Text(muse.title)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .padding(.top, 4)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
        .navigationBarHidden(true)
    }
}

@available(iOS 15.0, *)
struct ColorStoryView_Previews: PreviewProvider {
    static var previews: some View {
        ColorStoryView()
    }
}
