import SwiftUI

// MARK: - Share Sheet (UIActivityViewController wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - AuraDetailView

@available(iOS 14.0, *)
struct AuraDetailView: View {
    let item: AuraItem
    @ObservedObject var store: AuraStore
    @Environment(\.presentationMode) var presentationMode

    @State private var showingStore = false
    @State private var showingInsufficientAlert = false
    @State private var showingShareSheet = false
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    @State private var isGenerating = false
    @State private var generated = false
    @State private var generatedImage: UIImage?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Hero Image ──────────────────────────────────────
                    ZStack(alignment: .bottomLeading) {
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 420)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.7)],
                                    startPoint: .center, endPoint: .bottom
                                )
                            )

                        // Generated badge overlay
                        if generated {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("Generated!")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.55))
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(16)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(item.rarity.uppercased())
                                    .font(.system(size: 10, weight: .black))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.aiPink)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)

                                Text(item.crystalType.uppercased())
                                    .font(.system(size: 10, weight: .black))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.aiPurple.opacity(0.85))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }

                            Text(item.title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text(item.museName)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 24)
                    }

                    // ── Content ─────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 24) {

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Style Description", systemImage: "paintbrush.pointed.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.aiPurple)
                            Text(item.description)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }

                        Divider()

                        // AI Prompt Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("AI Prompt", systemImage: "wand.and.stars")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.aiPurple)
                                Spacer()
                                if store.isUnlocked(item) {
                                    Button(action: copyPrompt) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "doc.on.doc")
                                                .font(.system(size: 11))
                                            Text("Copy")
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                        .foregroundColor(.aiPurple)
                                    }
                                }
                            }

                            if store.isUnlocked(item) {
                                Text(item.prompt.isEmpty
                                     ? "A cinematic portrait with soft feminine lighting, dreamy atmosphere, ultra-detailed."
                                     : item.prompt)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .padding(14)
                                    .background(Color.aiPurple.opacity(0.06))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.aiPurple.opacity(0.2), lineWidth: 1)
                                    )
                            } else {
                                ZStack {
                                    Text("A cinematic portrait with soft feminine lighting, dreamy atmosphere, ultra-detailed skin, soft bokeh background, golden hour...")
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .padding(14)
                                        .blur(radius: 5)
                                    VStack(spacing: 8) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.aiPurple)
                                        Text("Unlock to view full prompt")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.aiPurple)
                                    }
                                }
                                .background(Color.aiPurple.opacity(0.04))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.aiPurple.opacity(0.15), lineWidth: 1)
                                )
                            }
                        }

                        Divider()

                        // Action Section
                        if store.isUnlocked(item) {
                            VStack(spacing: 14) {

                                // Generate button
                                Button(action: simulateGenerate) {
                                    HStack(spacing: 10) {
                                        if isGenerating {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.85)
                                        } else {
                                            Image(systemName: generated ? "checkmark.circle.fill" : "wand.and.stars")
                                                .font(.system(size: 18))
                                        }
                                        Text(isGenerating ? "Generating..." : generated ? "Generated! Generate Again" : "Generate with This Style")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.aiPurple, Color.aiPink],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .opacity(isGenerating ? 0.8 : 1.0)
                                }
                                .disabled(isGenerating)

                                // Tool buttons — only shown after generation
                                if generated {
                                    HStack(spacing: 12) {
                                        // Save Image
                                        ToolActionButton(icon: "arrow.down.circle.fill", label: "Save Image") {
                                            saveToLibrary()
                                        }

                                        // Share
                                        ToolActionButton(icon: "square.and.arrow.up", label: "Share") {
                                            shareImage()
                                        }

                                        // Wallpaper
                                        ToolActionButton(icon: "iphone", label: "Wallpaper") {
                                            setAsWallpaper()
                                        }
                                    }
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                        } else {
                            // Unlock CTA
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Premium Style")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Unlock to access the full AI prompt and generate images with this style.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .lineSpacing(4)
                                    }
                                    Spacer()
                                    VStack(spacing: 2) {
                                        Image(systemName: "pentagon.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.yellow)
                                        Text("\(item.unlockCost)")
                                            .font(.system(size: 18, weight: .black))
                                        Text("Credits")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(18)
                                .background(Color.aiPurple.opacity(0.06))
                                .cornerRadius(16)

                                Button(action: {
                                    if !store.unlock(item) { showingInsufficientAlert = true }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock.open.fill")
                                        Text("Unlock Style for \(item.unlockCost) Credits")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.aiPurple, Color.aiPink],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                }
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(22)
                    .background(Color(.systemBackground))
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                }
            }
            .edgesIgnoringSafeArea(.top)

            // Close button
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(radius: 4)
                    .padding(.top, 52)
                    .padding(.leading, 18)
            }
        }
        .alert(isPresented: $showingInsufficientAlert) {
            Alert(
                title: Text("Not Enough Credits"),
                message: Text("You need \(item.unlockCost) credits to unlock this style."),
                primaryButton: .default(Text("Get Credits")) { showingStore = true },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showingSaveAlert) {
            Alert(title: Text("Notice"), message: Text(saveMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingStore) {
            CoinStoreView(auraStore: store)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let img = generatedImage {
                ShareSheet(items: [img])
            }
        }
        .animation(.easeInOut(duration: 0.3), value: generated)
    }

    // MARK: - Actions

    /// 模拟生成：加载动画 2.2s 后标记完成，实际展示当前风格图
    func simulateGenerate() {
        guard !isGenerating else { return }
        generated = false
        isGenerating = true
        // 预先加载图片备用
        generatedImage = UIImage(named: item.imageName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            isGenerating = false
            generated = true
            // 生成成功后播放清脆的提示音，提供交互反馈
            AudioManager.shared.playSuccessChime()
        }
    }

    /// 复制 Prompt 到剪切板
    func copyPrompt() {
        let prompt = item.prompt.isEmpty
            ? "A cinematic portrait with soft feminine lighting, dreamy atmosphere, ultra-detailed."
            : item.prompt
        UIPasteboard.general.string = prompt
        saveMessage = "Prompt copied to clipboard!"
        showingSaveAlert = true
    }

    /// 保存图片到相册
    func saveToLibrary() {
        guard let image = UIImage(named: item.imageName) else {
            saveMessage = "Image not found."
            showingSaveAlert = true
            return
        }
        let saver = ImageSaver()
        saver.successHandler = {
            saveMessage = "Image saved to your Photos!"
            showingSaveAlert = true
        }
        saver.errorHandler = { _ in
            saveMessage = "Failed to save. Please allow Photos access in Settings."
            showingSaveAlert = true
        }
        saver.writeToPhotoAlbum(image: image)
    }

    /// 分享图片（调用系统分享面板）
    func shareImage() {
        generatedImage = UIImage(named: item.imageName)
        guard generatedImage != nil else {
            saveMessage = "Image not available for sharing."
            showingSaveAlert = true
            return
        }
        showingShareSheet = true
    }

    /// 壁纸：保存到相册并提示用户在系统相册中设置
    func setAsWallpaper() {
        guard let image = UIImage(named: item.imageName) else { return }
        let saver = ImageSaver()
        saver.successHandler = {
            saveMessage = "Saved to Photos!\n\nTo set as wallpaper:\nOpen Photos → Select this image → Share → Use as Wallpaper"
            showingSaveAlert = true
        }
        saver.writeToPhotoAlbum(image: image)
    }
}

// MARK: - Tool Action Button

struct ToolActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.aiPurple)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.aiPurple.opacity(0.07))
            .cornerRadius(14)
        }
    }
}
