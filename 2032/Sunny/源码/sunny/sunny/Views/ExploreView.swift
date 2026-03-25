import SwiftUI
import UIKit // Required for UIImage and UIImagePickerController

@available(iOS 14.0, *)
struct ExploreView: View {
    @ObservedObject var outfitsManager = OutfitsManager.shared
    
    // 用户选择的图片
    @State private var topImage: UIImage?
    @State private var bottomImage: UIImage?
    @State private var shoeImage: UIImage?
    
    // 图片选择器状态
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var activeSlot: SlotType = .top
    @State private var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    
    enum SlotType {
        case top, bottom, shoes
    }
    
    @State private var showSaveSuccess = false
    
    struct StyleReport: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let score: Int
        let category: String
        let colorAdvice: String
    }
    
    @State private var showStyleTip = false
    @State private var currentReport: StyleReport?
    @State private var showInsufficientCoins = false
    @State private var showCoinStoreSheet = false
    
    private let styleReports = [
        StyleReport(
            title: "Urban Chic Masterclass",
            description: "This combination strikes a perfect balance between comfort and high-fashion. The silhouette is modern and flattering.",
            score: 92,
            category: "Casual Professional",
            colorAdvice: "Consider adding a pop of crimson or deep emerald to break the neutral tones."
        ),
        StyleReport(
            title: "Minimalist Elegance",
            description: "Less is definitely more here. The clean lines of your selected pieces create a sophisticated, quiet luxury aesthetic.",
            score: 88,
            category: "Minimalist",
            colorAdvice: "Stick to cream, beige, and slate grey to maintain the elevated look."
        ),
        StyleReport(
            title: "Dynamic Streetwear",
            description: "A bold and energetic assembly. This look communicates confidence and an up-to-the-minute understanding of trends.",
            score: 95,
            category: "Streetwear",
            colorAdvice: "Neon accents or metallic accessories would further enhance this edgy vibe."
        ),
        StyleReport(
            title: "Classic Parisian",
            description: "Timeless and effortless. This pairing evokes a sense of European charm that works for almost any daytime occasion.",
            score: 90,
            category: "Classic",
            colorAdvice: "Navy blue and crisp white are your best friends for this specific set."
        ),
        StyleReport(
            title: "Avant-Garde Explorer",
            description: "You're pushing boundaries! The experimental nature of these pieces shows a unique and artistic fashion perspective.",
            score: 85,
            category: "Experimental",
            colorAdvice: "Try 'clashing' secondary colors like purple and mustard for a high-concept finish."
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.99, green: 0.98, blue: 0.96).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 标题
                        VStack(spacing: 8) {
                            Text("Closet Lab")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Mix & Match your own clothes")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // 交互组合区
                        VStack(spacing: 4) {
                            ClosetSlot(title: "Top / Dress", image: topImage, height: 180) {
                                activeSlot = .top
                                withAnimation { showActionSheet = true }
                            }
                            
                            ClosetSlot(title: "Bottom", image: bottomImage, height: 150) {
                                activeSlot = .bottom
                                withAnimation { showActionSheet = true }
                            }
                            
                            ClosetSlot(title: "Shoes / Bags", image: shoeImage, height: 100) {
                                activeSlot = .shoes
                                withAnimation { showActionSheet = true }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // 功能按钮
                        HStack(spacing: 20) {
                            Button(action: reset) {
                                Text("Clear All")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: saveLook) {
                                HStack {
                                    Image(systemName: showSaveSuccess ? "checkmark" : "heart.fill")
                                    Text(showSaveSuccess ? "Saved!" : "Save Look")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(isSelectionEmpty ? Color.gray.opacity(0.5) : (showSaveSuccess ? Color.green : Color(red: 1.0, green: 0.6, blue: 0.2)))
                                .cornerRadius(12)
                            }
                            .disabled(isSelectionEmpty)
                        }
                        .padding(.horizontal, 20)
                        
                        // 专家建议 (金币功能)
                        if !isSelectionEmpty {
                            VStack(spacing: 12) {
                                if let report = currentReport, showStyleTip {
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(report.title)
                                                    .font(.system(size: 18, weight: .bold))
                                                Text(report.category)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                            Spacer()
                                            
                                            // 评分圈
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                                                    .frame(width: 50, height: 50)
                                                Circle()
                                                    .trim(from: 0, to: CGFloat(report.score) / 100)
                                                    .stroke(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.2), .orange]), startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                                    .frame(width: 50, height: 50)
                                                    .rotationEffect(.degrees(-90))
                                                Text("\(report.score)")
                                                    .font(.system(size: 14, weight: .bold))
                                            }
                                        }
                                        
                                        Divider()
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Label("Expert Analysis", systemImage: "quote.opening")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(report.description)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                                .lineSpacing(4)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Label("Color Strategy", systemImage: "paintpalette.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(report.colorAdvice)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack {
                                            Spacer()
                                            Text("Verified Style Lab Report")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.gray.opacity(0.5))
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.blue.opacity(0.5))
                                        }
                                        .padding(.top, 5)
                                    }
                                    .padding(20)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
                                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                                } else {
                                    Button(action: unlockTip) {
                                        HStack {
                                            Image(systemName: "key.fill")
                                            Text("Unlock Pro Style Tip")
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Image(systemName: "bitcoinsign.circle.fill")
                                                Text("5")
                                            }
                                            .font(.system(size: 14, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(8)
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.1)]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(15)
                                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.3), radius: 8, x: 0, y: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                        
                        // 我的灵感簿预览
                        if !outfitsManager.savedOutfits.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("My Lookbook")
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(outfitsManager.savedOutfits.prefix(5)) { outfit in
                                            SavedOutfitPreview(outfit: outfit)
                                        }
                                        
                                        if outfitsManager.savedOutfits.count > 5 {
                                            NavigationLink(destination: AllOutfitsView()) {
                                                VStack {
                                                    Image(systemName: "ellipsis.circle")
                                                        .font(.system(size: 30))
                                                    Text("See All")
                                                        .font(.system(size: 12))
                                                }
                                                .frame(width: 80, height: 120)
                                                .background(Color.gray.opacity(0.05))
                                                .cornerRadius(12)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
                
                // 自定义来源选择弹出层 (放在 ZStack 里作为顶层覆盖)
                if showActionSheet {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation { showActionSheet = false }
                            }
                        
                        VStack(spacing: 20) {
                            Spacer()
                            
                            VStack(spacing: 0) {
                                Text("Select Photo Source")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 20)
                                
                                Divider()
                                
                                SourceButton(icon: "camera.fill", title: "Take Photo", color: .blue) {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        selectedSource = .camera
                                        showActionSheet = false
                                        showImagePicker = true
                                    }
                                }
                                
                                Divider()
                                
                                SourceButton(icon: "photo.on.rectangle.angled", title: "Photo Library", color: .orange) {
                                    selectedSource = .photoLibrary
                                    showActionSheet = false
                                    showImagePicker = true
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                            
                            Button(action: {
                                withAnimation { showActionSheet = false }
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .transition(.move(edge: .bottom))
                    }
                    .zIndex(10)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: Binding(
                    get: {
                        switch activeSlot {
                        case .top: return topImage
                        case .bottom: return bottomImage
                        case .shoes: return shoeImage
                        }
                    },
                    set: { newValue in
                        switch activeSlot {
                        case .top: topImage = newValue
                        case .bottom: bottomImage = newValue
                        case .shoes: shoeImage = newValue
                        }
                        // 更换单品时重置建议
                        showStyleTip = false
                        currentReport = nil
                    }
                ), sourceType: selectedSource)
                .edgesIgnoringSafeArea(.all)
            }
            .alert(isPresented: $showInsufficientCoins) {
                Alert(
                    title: Text("Insufficient Coins"),
                    message: Text("You need 5 coins to unlock a style tip. Would you like to get more?"),
                    primaryButton: .default(Text("Get Coins")) {
                        showCoinStoreSheet = true
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showCoinStoreSheet) {
                if #available(iOS 15.0, *) {
                    CoinStoreView()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }

    
    var isSelectionEmpty: Bool {
        topImage == nil && bottomImage == nil && shoeImage == nil
    }
    
    func reset() {
        withAnimation {
            topImage = nil
            bottomImage = nil
            shoeImage = nil
            showStyleTip = false
            currentReport = nil
        }
    }
    
    func saveLook() {
        outfitsManager.saveOutfit(top: topImage, bottom: bottomImage, shoes: shoeImage)
        
        withAnimation {
            showSaveSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }
    
    func unlockTip() {
        if CoinManager.shared.spendCoins(5) {
            currentReport = styleReports.randomElement()
            withAnimation(.spring()) {
                showStyleTip = true
            }
        } else {
            showInsufficientCoins = true
        }
    }
}



struct SourceButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
        }
    }
}

struct ClosetSlot: View {

    let title: String
    let image: UIImage?
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .clipped()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                        Text(title)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(Color.gray.opacity(0.05))
                }
            }
        }
    }
}

struct SavedOutfitPreview: View {
    let outfit: SavedOutfit
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let path = outfit.topPath, let uiImage = loadImage(path) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill).frame(width: 80, height: 50).clipped()
                } else {
                    Color.gray.opacity(0.1).frame(width: 80, height: 50)
                }
                
                if let path = outfit.bottomPath, let uiImage = loadImage(path) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill).frame(width: 80, height: 40).clipped()
                } else {
                    Color.gray.opacity(0.1).frame(width: 80, height: 40)
                }
                
                if let path = outfit.shoesPath, let uiImage = loadImage(path) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill).frame(width: 80, height: 30).clipped()
                } else {
                    Color.gray.opacity(0.1).frame(width: 80, height: 30)
                }
            }
        }
        .frame(width: 80, height: 120)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
    
    func loadImage(_ path: String) -> UIImage? {
        let url = OutfitsManager.shared.getImagePath(path)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}

struct AllOutfitsView: View {
    @ObservedObject var outfitsManager = OutfitsManager.shared
    
    var body: some View {
        List {
            ForEach(outfitsManager.savedOutfits) { outfit in
                HStack(spacing: 15) {
                    SavedOutfitPreview(outfit: outfit)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Combination")
                            .font(.headline)
                        if #available(iOS 14.0, *) {
                            Text(outfit.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .onDelete(perform: outfitsManager.deleteOutfit)
        }
        .navigationBarTitle("My Lookbook", displayMode: .inline)
    }
}



struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            ExploreView()
        } else {
            Text("Requires iOS 14+")
        }
    }
}
