import SwiftUI

struct PhotoDetailView: View {
    let photo: PhotoModel
    @State private var isSaved: Bool = false
    @State private var showingCamera: Bool = false
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main Image
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: URL(string: photo.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 400)
                        }
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 400)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .overlay(Text("Requires iOS 15").foregroundColor(.gray))
                    }
                    
                    // Try this Pose Button (The core feature)
                    if #available(iOS 14.0, *) {
                        Button(action: {
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text("Try this Pose")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .fullScreenCover(isPresented: $showingCamera) {
                            PoseCameraView(photoUrl: photo.imageUrl)
                        }
                    }
                    
                    // Header & Action
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(photo.category.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text(photo.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                toggleSave()
                            }) {
                                if #available(iOS 14.0, *) {
                                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                        .font(.title2)
                                        .foregroundColor(isSaved ? .blue : .primary)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                        
                        Text(photo.subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(photo.stylingTags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                        Divider().padding(.top, 10)
                        
                        if #available(iOS 14.0, *) {
                            Text("Pose Analysis")
                                .font(.title3)
                                .fontWeight(.bold)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    .padding(.horizontal)
                    
                    // Pose Tips
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(photo.poseTips) { tip in
                            HStack(alignment: .top, spacing: 16) {
                                if #available(iOS 14.0, *) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                        .padding(.top, 2)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tip.title)
                                        .font(.headline)
                                    
                                    Text(tip.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .onAppear {
                checkIfSaved()
            }
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            // Fallback on earlier versions
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
    }
    
    private func checkIfSaved() {
        let savedIds = UserDefaults.standard.stringArray(forKey: "savedPhotoIds") ?? []
        isSaved = savedIds.contains(photo.id)
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhotoDetailView(photo: PhotoModel.mockData[0])
        }
    }
}
