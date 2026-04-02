import SwiftUI

@available(iOS 15.0, *)
struct MuseDetailView: View {
    let muse: MuseItem
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MAGAZINE HEADER
                ZStack(alignment: .bottomLeading) {
                    Image(muse.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 500)
                        .clipped()
                    
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(muse.category.uppercased())
                            .font(.system(size: 12, weight: .black))
                            .tracking(4)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(muse.title)
                            .font(.system(size: 48, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(muse.location)
                                .font(.system(size: 14, design: .serif))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(30)
                }
                
                VStack(alignment: .leading, spacing: 32) {
                    // STORY SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Aesthetic Vision")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        Text(muse.story)
                            .font(.system(size: 20, design: .serif))
                            .lineSpacing(8)
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    // ATTRIBUTES SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ATTRIBUTES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(muse.aestheticAttributes, id: \.self) { attr in
                                    Text(attr)
                                        .font(.system(size: 14, weight: .medium, design: .serif))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    // COLOR PALETTE SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("COLOR STORY")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        HStack(spacing: 16) {
                            ForEach(muse.colorPalette, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 45, height: 45)
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // CTA BUTTON
                    Button(action: openInStudio) {
                        HStack {
                            Image(systemName: "camera.filters")
                            Text("OPEN IN STUDIO")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.black)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30)
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .overlay(
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.9)))
                    .shadow(radius: 5)
            }
            .padding(.leading, 20)
            .padding(.top, 50)
            , alignment: .topLeading
        )
    }
    
    private func openInStudio() {
        // This will be implemented via MainTabView selection
        NotificationCenter.default.post(name: NSNotification.Name("OpenStudioWithMuse"), object: muse)
    }
}

@available(iOS 15.0, *)
struct MuseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MuseDetailView(muse: AssetManager().muses[0])
    }
}
