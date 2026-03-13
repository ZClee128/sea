import SwiftUI

struct StudioView: View {
    @ObservedObject var appState: AppState
    
    var savedPictures: [PictureModel] {
        // mockPictures defined in PictureModel.swift
        pictures.filter { appState.favoriteItems.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Profile Header
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if #available(iOS 14.0, *) {
                                Text("Beauty Enthusiast")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            } else {
                                // Fallback on earlier versions
                            }
                            Text("Your personal studio & tools")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Saved Collection Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("My Collection")
                                .font(.headline)
                            Spacer()
                            Text("\(savedPictures.count) saved")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if savedPictures.isEmpty {
                            VStack {
                                Image(systemName: "bookmark.slash")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                                Text("No looks saved yet.")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(savedPictures) { picture in
                                        NavigationLink(destination: DetailView(appState: appState, picture: picture)) {
                                            Image(picture.imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 140, height: 200)
                                                .clipped()
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Beauty Tools Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Beauty Tools")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Tool 1: Pocket Mirror (Replacement for Face Quiz)
                        NavigationLink(destination: MirrorView()) {
                            HStack {
                                ZStack {
                                    Color.accentColor.opacity(0.2)
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(8)
                                    Image(systemName: "camera.macro")
                                        .foregroundColor(.accentColor)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Pocket Mirror")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text("Check your look in real-time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Tool 2: Color Match Guide
                        NavigationLink(destination: ColorGuideView()) {
                            HStack {
                                ZStack {
                                    Color.purple.opacity(0.2)
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(8)
                                    Image(systemName: "paintpalette")
                                        .foregroundColor(.purple)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Color Match Guide")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text("Learn how to pair lip colors with skin tones")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Studio")
        }
    }
}

// New sub-feature: A color pairing guide
struct ColorGuideView: View {
    let guides = [
        ("Fair Skin", "Cool Undertones: Berry, Plum\nWarm Undertones: Peach, Coral", "E8B4B8"),
        ("Medium Skin", "Cool Undertones: Cranberry\nWarm Undertones: Copper", "D2B48C"),
        ("Olive Skin", "Cool Undertones: Brick Red\nWarm Undertones: Caramel", "BDB76B"),
        ("Deep Skin", "Cool Undertones: Deep Violet\nWarm Undertones: Rich Ruby", "8B4513")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Understanding your undertone helps in picking the perfect palette for your daily style.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                
                ForEach(guides, id: \.0) { guide in
                    HStack(spacing: 15) {
                        Circle()
                            .fill(Color(hex: guide.2))
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(guide.0)
                                .font(.headline)
                            Text(guide.1)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitle("Color Guide", displayMode: .inline)
    }
}
