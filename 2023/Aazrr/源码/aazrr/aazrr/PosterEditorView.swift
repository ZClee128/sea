import SwiftUI

struct PosterEditorView: View {
    let portrait: Portrait
    @Environment(\.presentationMode) var presentationMode
    
    @State private var quoteText: String
    @State private var fontColor: Color = .white
    @State private var alignment: TextAlignment = .center
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage?
    
    // Premium Features
    @ObservedObject var storeManager = StoreManager.shared
    @State private var showCoinPrompt = false
    @State private var showInsufficientFunds = false
    @State private var pendingAction: (() -> Void)?
    
    init(portrait: Portrait) {
        self.portrait = portrait
        self._quoteText = State(initialValue: portrait.defaultQuote)
    }
    
    var posterContent: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 0) {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(portrait.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: 400)
                .clipped()
                
                VStack(spacing: 20) {
                    Text("\"\(quoteText)\"")
                        .font(.custom("Georgia", size: 24))
                        .italic()
                        .multilineTextAlignment(alignment)
                        .foregroundColor(fontColor)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        Text("- \(portrait.personName)")
                            .font(.headline)
                            .foregroundColor(fontColor.opacity(0.8))
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                
                Spacer()
            }
        }
        .frame(width: min(UIScreen.main.bounds.width - 40, 400))
        .frame(height: min(UIScreen.main.bounds.height - 200, 600))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Text("Editor")
                    .font(.headline)
                Spacer()
                Button(action: { promptCoinCharge(for: sharePoster) }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                }
                .padding(.trailing, 10)
                Button("Save") {
                    promptCoinCharge(for: savePoster)
                }
                .disabled(quoteText.isEmpty)
            }
            .padding()
            
            ScrollView {
                // The actual preview
                posterContent
                    .padding(.top, 20)
                
                // Controls
                VStack(spacing: 20) {
                    TextField("Quote", text: $quoteText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack(spacing: 30) {
                        Button(action: { alignment = .leading }) {
                            Image(systemName: "text.alignleft").font(.title).foregroundColor(alignment == .leading ? .blue : .gray)
                        }
                        Button(action: { alignment = .center }) {
                            Image(systemName: "text.aligncenter").font(.title).foregroundColor(alignment == .center ? .blue : .gray)
                        }
                        Button(action: { alignment = .trailing }) {
                            Image(systemName: "text.alignright").font(.title).foregroundColor(alignment == .trailing ? .blue : .gray)
                        }
                    }
                    
                    HStack {
                        Text("Color:")
                        ColorPickerButton(color: .white, selectedColor: $fontColor)
                        ColorPickerButton(color: .yellow, selectedColor: $fontColor)
                        ColorPickerButton(color: .green, selectedColor: $fontColor)
                        ColorPickerButton(color: .blue, selectedColor: $fontColor)
                        ColorPickerButton(color: .red, selectedColor: $fontColor)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top, 30)
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { showSaveSuccess || showCoinPrompt || showInsufficientFunds },
            set: { _ in }
        )) {
            if showCoinPrompt {
                return Alert(
                    title: Text("Premium Action"),
                    message: Text("Saving or sharing this high-quality poster costs 10 coins. You have \(storeManager.coinBalance) coins."),
                    primaryButton: .default(Text("Pay 10 Coins")) {
                        if storeManager.deductCoins(10) {
                            showCoinPrompt = false
                            pendingAction?()
                        } else {
                            showCoinPrompt = false
                            // Small delay to allow previous alert to dismiss
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.showInsufficientFunds = true
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        showCoinPrompt = false
                        pendingAction = nil
                    }
                )
            } else if showInsufficientFunds {
                return Alert(
                    title: Text("Insufficient Coins"),
                    message: Text("You need 10 coins to perform this action. Please visit the Premium Store in the Settings tab to top up."),
                    dismissButton: .default(Text("OK")) {
                        showInsufficientFunds = false
                    }
                )
            } else {
                return Alert(
                    title: Text("Saved!"),
                    message: Text("Poster has been saved to your Photo Library."),
                    dismissButton: .default(Text("OK")) {
                        showSaveSuccess = false
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = self.imageToShare {
                ActivityView(activityItems: [img])
            }
        }
    }
    
    private func promptCoinCharge(for action: @escaping () -> Void) {
        self.pendingAction = action
        self.showCoinPrompt = true
    }
    
    private func sharePoster() {
        self.imageToShare = posterContent.snapshot()
        self.showShareSheet = true
    }
    
    private func savePoster() {
        isSaving = true
        let snapshot = posterContent.snapshot()
        let saver = ImageSaver()
        saver.successHandler = {
            self.showSaveSuccess = true
            self.isSaving = false
        }
        saver.errorHandler = { error in
            print("Error saving: \(error.localizedDescription)")
            self.isSaving = false
        }
        saver.writeToPhotoAlbum(image: snapshot)
    }
}

struct ColorPickerButton: View {
    let color: Color
    @Binding var selectedColor: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(Color.gray, lineWidth: selectedColor == color ? 3 : 1)
            )
            .onTapGesture {
                selectedColor = color
            }
    }
}

// Extension to render View to UIImage (iOS 13+)
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        let bounds = CGRect(origin: .zero, size: targetSize)
        
        // Handle iOS 13 minimum constraints where intrinsic content size might be zero
        let finalSize = targetSize.width > 0 ? targetSize : CGSize(width: 400, height: 600)
        view?.bounds = CGRect(origin: .zero, size: finalSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: finalSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
