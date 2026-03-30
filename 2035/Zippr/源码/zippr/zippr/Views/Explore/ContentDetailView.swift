import SwiftUI

@available(iOS 14.0, *)
struct ContentDetailView: View {
    let item: ContentItem
    @StateObject private var favManager = FavoritesManager.shared
    @StateObject private var timerManager = WorkoutTimerManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var showTimer = false
    @State private var timerSeconds = 0
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @State private var showCompletionBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.zBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroImage
                    contentBody
                        .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Floating back + fav buttons
            overlayButtons

            // Completion banner
            if showCompletionBanner {
                completionBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onDisappear { stopTimer() }
    }

    // MARK: - Hero Image
    private var heroImage: some View {
        ZStack(alignment: .bottomLeading) {
            // overlay pattern — Color frame is rock-solid, image cannot expand it
            if #available(iOS 15.0, *) {
                Color.zPrimary.opacity(0.3)
                    .overlay(
                        Image(item.title)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    )
                    .frame(height: 320)
                    .clipped()
            } else {
                // Fallback on earlier versions
            }

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.6)],
                startPoint: .center, endPoint: .bottom
            )
            .frame(height: 320)

            VStack(alignment: .leading, spacing: 6) {
                DifficultyBadge(level: item.difficulty)
                Text(item.title)
                    .font(.zTitle(26))
                    .foregroundColor(.white)
                Text(item.subtitle)
                    .font(.zBody(14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Content body
    private var contentBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Stats row
            HStack(spacing: 0) {
                statItem(icon: "clock", value: item.duration, label: "Duration")
                Divider().frame(height: 40)
                statItem(icon: "flame.fill", value: "\(item.calories)", label: "Calories")
                Divider().frame(height: 40)
                statItem(icon: "tag.fill", value: item.category, label: "Category")
            }
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.zPrimary.opacity(0.06), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.top, 20)

            // Tags
            tagsSection

            // Timer section
            timerSection

            // Start button
            startWorkoutButton
            
            // Chat with Coach button
            if #available(iOS 15.0, *) {
                chatWithCoachButton
            }
        }
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Color.zPrimary)
                .font(.system(size: 18))
            Text(value)
                .font(.zHeadline(15))
                .foregroundColor(Color.zText)
            Text(label)
                .font(.zCaption(11))
                .foregroundColor(Color.zTextSub)
        }
        .frame(maxWidth: .infinity)
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.zHeadline(16))
                .foregroundColor(Color.zText)
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.zCaption(12))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.zCardBg)
                            .foregroundColor(Color.zPrimary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Timer section
    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Timer")
                .font(.zHeadline(16))
                .foregroundColor(Color.zText)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(colors: [Color.zPrimary.opacity(0.07), Color.zAccent.opacity(0.04)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                VStack(spacing: 14) {
                    // Big clock
                    Text(timeString(timerSeconds))
                        .font(.system(size: 52, weight: .thin, design: .monospaced))
                        .foregroundColor(Color.zText)

                    // Controls
                    HStack(spacing: 20) {
                        Button {
                            timerSeconds = 0
                            stopTimer()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20))
                                .foregroundColor(Color.zTextSub)
                                .frame(width: 48, height: 48)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                        }

                        Button {
                            timerRunning ? stopTimer() : startTimer()
                        } label: {
                            Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.zPrimary.opacity(0.4), radius: 10, x: 0, y: 4)
                        }

                        Button {
                            if timerSeconds > 0 {
                                stopTimer()
                                recordCompletion()
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20))
                                .foregroundColor(timerSeconds > 0 ? Color.zPrimary : Color.zTextSub.opacity(0.4))
                                .frame(width: 48, height: 48)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                        }
                        .disabled(timerSeconds == 0)
                    }
                }
                .padding(.vertical, 24)
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
    }

    private var startWorkoutButton: some View {
        Button {
            startTimer()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                Text("Start Workout")
                    .font(.zHeadline(17))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                               startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(16)
            .shadow(color: Color.zPrimary.opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 16)
    }
    
    @available(iOS 15.0, *)
    private var chatWithCoachButton: some View {
        NavigationLink(destination: CoachChatView(coachName: item.coachName)) {
            HStack(spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Chat with Coach")
                    .font(.zHeadline(17))
            }
            .foregroundColor(Color.zPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.zPrimary.opacity(0.2), lineWidth: 1.5)
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Overlay buttons
    private var overlayButtons: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            Spacer()
            Button {
                withAnimation(.spring()) { favManager.toggle(item.id) }
            } label: {
                Image(systemName: favManager.isFavorite(item.id) ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(favManager.isFavorite(item.id) ? Color.zPrimary : .white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, safeTopInset + 8)
    }

    // MARK: - Completion Banner
    private var completionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Workout Saved! 🔥")
                    .font(.zHeadline(14))
                    .foregroundColor(.white)
                Text("Great job! Keep up the streak.")
                    .font(.zCaption(12))
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                           startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.top, safeTopInset + 8)
    }

    // MARK: - Timer helpers
    private func startTimer() {
        guard !timerRunning else { return }
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerSeconds += 1
        }
    }

    private func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func recordCompletion() {
        timerManager.recordWorkout(seconds: timerSeconds)
        timerSeconds = 0
        withAnimation(.spring()) { showCompletionBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showCompletionBanner = false }
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private var safeTopInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
    }
}
