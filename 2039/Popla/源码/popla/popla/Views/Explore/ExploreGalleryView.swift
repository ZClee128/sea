import SwiftUI

// Full Screen Immersive View (Using SHARED ViewModel)
import AVKit
import Combine

@available(iOS 15.0, *)
struct ExploreGalleryView: View {
    @State private var activeRhythm = "All"
    let rhythms = ["All", "Relax", "Energetic", "Creative", "Silent"]
    @ObservedObject var collectionManager = CollectionManager.shared
    
    // Shared data source for consistency
    let sampleData = MomentsData.all
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 50) {
                        
                        DailyVibeHeader()
                        
                        // Community Spotlight (Featured Boosted Spots)
                        let boostedSpots = collectionManager.contributedSpots.filter { $0.isBoosted }
                        if !boostedSpots.isEmpty {
                            CommunityFeaturedSection(spots: boostedSpots)
                        }
                        
                        // Filter Area
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(rhythms, id: \.self) { rhythm in
                                    Button(action: { activeRhythm = rhythm }) {
                                        Text(rhythm)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(activeRhythm == rhythm ? .black : .gray.opacity(0.3))
                                            .overlay(
                                                activeRhythm == rhythm ? 
                                                Capsule().fill(Color.black).frame(height: 2).offset(y: 12) : nil
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        .padding(.bottom, 20)
                        
                        // Modular Content Flow
                        let filtered = sampleData.filter { activeRhythm == "All" || $0.rhythm == activeRhythm }
                        
                        ForEach(Array(filtered.enumerated()), id: \.offset) { index, moment in
                            NavigationLink(destination: DetailView(moment: moment)) {
                                if index % 3 == 0 {
                                    BannerModule(moment: moment)
                                } else if index % 3 == 1 {
                                    SideModule(moment: moment, photoOnLeft: true)
                                } else {
                                    SideModule(moment: moment, photoOnLeft: false)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

@available(iOS 14.0, *)
struct CommunityFeaturedSection: View {
    let spots: [DiscoverySpot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("COMMUNITY FEATURED")
                    .font(.system(size: 12, weight: .black))
                    .tracking(2)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(spots) { spot in
                        NavigationLink(destination: ContributionDetailView(spot: spot)) {
                            VStack(alignment: .leading, spacing: 10) {
                                ZStack(alignment: .topTrailing) {
                                    if let data = spot.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.black.opacity(0.05)
                                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                    }
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 10))
                                        .padding(8)
                                        .background(Color.yellow)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .padding(10)
                                }
                                .frame(width: 240, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                                
                                Text(spot.title.uppercased())
                                    .font(.system(size: 14, weight: .black))
                                    .tracking(1)
                                    .padding(.leading, 5)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

struct DailyVibeHeader: View {
    @State private var isShowingSuggest = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("COLLECTION")
                    .font(.system(size: 10, weight: .black))
                    .tracking(5)
                    .foregroundColor(.gray.opacity(0.4))
                
                Spacer()
                
                Button(action: { isShowingSuggest = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("SUGGEST").font(.system(size: 10, weight: .black))
                    }
                    .padding(.horizontal, 15).padding(.vertical, 8)
                    .background(Color.black.opacity(0.05)).cornerRadius(20)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Urban")
                    .font(.custom("HelveticaNeue-CondensedBold", size: 54))
                Text("Aura")
                    .font(.custom("HelveticaNeue-Thin", size: 54))
            }
            .foregroundColor(.black)
        }
        .padding(.horizontal, 30)
        .padding(.top, 40)
        .sheet(isPresented: $isShowingSuggest) {
            if #available(iOS 14.0, *) {
                SuggestionView()
            }
        }
    }
}

struct BannerModule: View {
    let moment: UrbanMoment
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Color.clear
                .frame(height: 320)
                .frame(maxWidth: .infinity)
                .overlay(
                    Image(moment.title)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    VStack {
                        HStack {
                            Button(action: { collectionManager.toggleCollection(moment.title) }) {
                                Image(systemName: collectionManager.isSaved(moment.title) ? "suit.heart.fill" : "suit.heart")
                                    .font(.system(size: 18))
                                    .foregroundColor(collectionManager.isSaved(moment.title) ? .red : .white.opacity(0.8))
                                    .padding(12)
                                    .background(BlurView(style: .systemMaterialLight).opacity(0.3))
                                    .clipShape(Circle())
                            }
                            .padding(20)
                            
                            Spacer()
                            Text("NO. " + moment.number)
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(25)
                        }
                        Spacer()
                        if moment.isVideo {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 45))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.bottom, 120)
                        }
                    }
                )
                .padding(.horizontal, 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(moment.title.uppercased())
                    .font(.system(size: 20, weight: .black))
                    .tracking(2)
                Text(moment.location)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 35)
        }
    }
}

struct SideModule: View {
    let moment: UrbanMoment
    let photoOnLeft: Bool
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var body: some View {
        HStack(alignment: .center, spacing: 25) {
            if photoOnLeft {
                photoPart
                textPart
                Spacer()
            } else {
                Spacer()
                textPart
                photoPart
            }
        }
        .padding(.horizontal, 30)
    }
    
    var photoPart: some View {
        Color.clear
            .frame(width: 160, height: 240)
            .overlay(
                Image(moment.title)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                VStack {
                    HStack {
                        Button(action: { collectionManager.toggleCollection(moment.title) }) {
                            Image(systemName: collectionManager.isSaved(moment.title) ? "suit.heart.fill" : "suit.heart")
                                .font(.system(size: 14))
                                .foregroundColor(collectionManager.isSaved(moment.title) ? .red : .white.opacity(0.8))
                                .padding(8)
                                .background(BlurView(style: .systemMaterialLight).opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(12)
                        Spacer()
                        Text(moment.number)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(15)
                    }
                    Spacer()
                    if moment.isVideo {
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(15)
                    }
                }
            )
    }
    
    var textPart: some View {
        VStack(alignment: photoOnLeft ? .leading : .trailing, spacing: 10) {
            Text(moment.title.uppercased())
                .font(.system(size: 14, weight: .black))
                .tracking(1)
            Text(moment.location)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray.opacity(0.6))
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 30, height: 1)
        }
    }
}

@available(iOS 14.0, *)
struct SuggestionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var spotName = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isSubmitted = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isSubmitted {
                    VStack(spacing: 20) {
                        Image(systemName: "hand.thumbsup.fill").font(.system(size: 60))
                        Text("Contribution Received").font(.system(size: 24, weight: .black))
                        Text("The city grows through its people. We'll review your spot soon.").multilineTextAlignment(.center).padding(.horizontal, 40).foregroundColor(.secondary)
                    }
                } else {
                    Form {
                        Section(header: Text("UPLOAD PHOTO")) {
                            Button(action: { showingImagePicker = true }) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 180)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Select from library")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                    .background(Color.black.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Section(header: Text("WHAT DID YOU DISCOVER?")) {
                            TextField("Name of the spot", text: $spotName)
                            TextEditor(text: $description)
                                .frame(height: 100)
                        }
                        
                        Button(action: { 
                            withAnimation { 
                                let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
                                CollectionManager.shared.addSuggestion(spotName, category: "Hidden Discovery", imageData: imageData)
                                isSubmitted = true 
                            }
                            hideKeyboard()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { presentationMode.wrappedValue.dismiss() }
                        }) {
                            Text("Submit to Community Archive")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                        .disabled(spotName.isEmpty)
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
            .navigationBarTitle("Suggest a Spot", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") { presentationMode.wrappedValue.dismiss() })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

// Global Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

@available(iOS 14.0, *)
struct DetailView: View {
    let moment: UrbanMoment
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var playerVM = PlayerViewModel()
    @State private var isFullScreen = false
    @State private var isChatting = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 45) {
                    if moment.isVideo {
                        mediaPlayerSection
                    } else {
                        mediaImageSection
                    }
                    
                    VStack(alignment: .leading, spacing: 25) {
                        headerSection
                        Text(moment.fullDescription.isEmpty ? "This unique perspective captures the true essence of city rhythm." : moment.fullDescription)
                            .font(.system(size: 19))
                            .lineSpacing(10)
                            .foregroundColor(.black.opacity(0.8))
                        tagCloudSection
                    }
                    .padding(.horizontal, 30)
                    
                    curatorSection
                    Spacer().frame(height: 120)
                }
                .padding(.top, 10)
            }
            .navigationBarTitle(Text("Editorial"), displayMode: .inline)
            .navigationBarItems(trailing: 
                Button(action: { CollectionManager.shared.toggleCollection(moment.title) }) {
                    Image(systemName: CollectionManager.shared.isSaved(moment.title) ? "suit.heart.fill" : "suit.heart")
                        .font(.system(size: 18))
                        .foregroundColor(CollectionManager.shared.isSaved(moment.title) ? .red : .black.opacity(0.8))
                        .padding(5)
                }
            )
            
            contactButton
                .padding(.bottom, 60) 
        }
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear { playerVM.cleanup() }
        .sheet(isPresented: $isFullScreen) {
            FullScreenVideoView(playerVM: playerVM).environmentObject(appSettings)
        }
        .fullScreenCover(isPresented: $isChatting) {
            IMChatView(viewModel: IMViewModel(curatorName: moment.curatorName))
        }
    }
    
    private var mediaPlayerSection: some View {
        ZStack(alignment: .bottomTrailing) {
            UrbanVideoPlayer(player: playerVM.player)
                .id(isChatting)
                .frame(height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 35))
            
            Button(action: { playerVM.isPlaying.toggle() }) {
                Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30)).foregroundColor(.white).frame(width: 70, height: 70)
                    .background(Color.black.opacity(0.2)).clipShape(Circle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: { isFullScreen = true }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.white).padding(12)
                    .background(Color.black.opacity(0.5)).clipShape(Circle())
            }
            .padding(25)
        }
        .padding(.horizontal, 25)
        .onAppear { playerVM.setup(videoUrl: moment.videoUrl) }
    }
    
    private var mediaImageSection: some View {
        Color.clear.frame(height: 480).frame(maxWidth: .infinity)
            .overlay(
                Image(moment.title)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
            .clipShape(RoundedRectangle(cornerRadius: 35)).padding(.horizontal, 25)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NO. " + moment.number).font(.system(size: 12, weight: .black)).foregroundColor(.secondary.opacity(0.5))
            Text(moment.title).font(.system(size: 42, weight: .black)).foregroundColor(.black)
            HStack {
                Label(moment.rhythm, systemImage: "sparkles")
                Spacer()
                Label(moment.location, systemImage: "mappin.circle.fill")
            }.font(.system(size: 13, weight: .bold)).foregroundColor(.secondary)
            Divider().padding(.top, 15)
        }
    }
    
    private var tagCloudSection: some View {
        HStack(spacing: 12) {
            ForEach(moment.tags, id: \.self) { tag in
                Text("#" + tag)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.black.opacity(0.06)).cornerRadius(10)
            }
        }
    }
    
    private var curatorSection: some View {
        VStack(spacing: 20) {
            Divider()
            HStack(spacing: 20) {
                Circle().fill(Color.black.opacity(0.05)).frame(width: 65, height: 65)
                    .overlay(Text(String(moment.curatorName.prefix(1))).font(.system(size: 24, weight: .black)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(moment.curatorName).font(.system(size: 18, weight: .black))
                    Text(moment.curatorBio).font(.system(size: 12)).foregroundColor(.secondary).lineLimit(2)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 30).padding(.top, 20)
    }
    
    private var contactButton: some View {
        Button(action: { isChatting = true }) {
            HStack(spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Talk to Curator").font(.system(size: 14, weight: .black))
            }
                .padding(.horizontal, 22).padding(.vertical, 16)
                .background(Color.black).foregroundColor(.white).cornerRadius(35)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .padding(30)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

@available(iOS 14.0, *)
struct FullScreenVideoView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            UrbanVideoPlayer(player: playerVM.player)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

extension UrbanMoment {
    var rhythmLabel: String {
        return self.isVideo ? "Live Reel" : self.rhythm
    }
}
