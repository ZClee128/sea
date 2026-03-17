import SwiftUI

@available(iOS 14.0, *)
struct PhotoDetailView: View {
    let photo: PhotoModel
    @State private var showingCamera = false
    @State private var isSaved: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .bottomLeading) {
                    Image(photo.imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .clipped()
                    
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(photo.category.uppercased())
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(photo.title.uppercased())
                            .font(.system(size: 36, weight: .black, design: .serif))
                            .foregroundColor(.white)
                    }
                    .padding(25)
                }
                
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("STYLING NOTES")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 10) {
                                ForEach(photo.stylingTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            Button(action: { toggleSave() }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.title2)
                                    .foregroundColor(isSaved ? .black : .primary)
                            }
                            
                            Button(action: { showingCamera = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "camera.viewfinder")
                                    Text("TRY THIS POSE")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .cornerRadius(30)
                                .shadow(radius: 5)
                            }
                            .fullScreenCover(isPresented: $showingCamera) {
                                CameraView(overlayImage: photo.imageUrl)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("POSING GUIDE")
                            .font(.system(size: 14, weight: .heavy))
                            .tracking(1)
                        
                        ForEach(photo.poseTips) { tip in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(tip.title.uppercased())
                                    .font(.system(size: 13, weight: .bold))
                                Text(tip.description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    
                    Text(photo.subtitle)
                        .font(.body)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
                .padding(25)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            checkIfSaved()
        }
    }
    
    private func toggleSave() {
        var savedIds = UserDefaults.standard.stringArray(forKey: "savedPhotoIds") ?? []
        if isSaved {
            savedIds.removeAll { $0 == photo.id }
        } else {
            savedIds.append(photo.id)
        }
        UserDefaults.standard.set(savedIds, forKey: "savedPhotoIds")
        isSaved.toggle()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func checkIfSaved() {
        let savedIds = UserDefaults.standard.stringArray(forKey: "savedPhotoIds") ?? []
        isSaved = savedIds.contains(photo.id)
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            PhotoDetailView(photo: PhotoModel.mockData[0])
        }
    }
}
