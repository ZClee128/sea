import SwiftUI

struct PracticeModeView: View {
    @State private var selectedTime: Int = 60 // seconds
    let timeOptions = [30, 60, 120, 300]
    @State private var isSessionActive = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 8) {
                    Text("Gesture Practice")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("Sharpen your skills with timed reference drawing sessions.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time per reference")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Time Interval", selection: $selectedTime) {
                        ForEach(timeOptions, id: \.self) { time in
                            Text("\(time)s").tag(time)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    isSessionActive = true
                }) {
                    Text("Start Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .navigationBarTitle("Practice", displayMode: .inline)
            .sheet(isPresented: $isSessionActive) {
                ActiveSessionView(timeLimit: selectedTime, artworks: MockData.artworks.shuffled(), isPresented: $isSessionActive)
            }
        }
    }
}

struct ActiveSessionView: View {
    let timeLimit: Int
    let artworks: [Artwork]
    @Binding var isPresented: Bool
    
    @State private var currentIndex = 0
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var backgroundDate: Date? = nil
    
    init(timeLimit: Int, artworks: [Artwork], isPresented: Binding<Bool>) {
        self.timeLimit = timeLimit
        self.artworks = artworks
        self._isPresented = isPresented
        self._timeRemaining = State(initialValue: timeLimit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Button(action: {
                    stopTimer()
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(timeString(time: timeRemaining))
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining <= 5 ? .red : .primary)
                Spacer()
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Image area
            if !artworks.isEmpty {
                if let uiImage = UIImage(named: artworks[currentIndex].title) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: artworks[currentIndex].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        Text("Asset Missing: \(artworks[currentIndex].title)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Please add this image to Assets.xcassets")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                }
            } else {
                Text("No references available.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if !isPaused {
                backgroundDate = Date()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if let bgDate = backgroundDate, !isPaused {
                let elapsed = Int(Date().timeIntervalSince(bgDate))
                handleBackgroundElapsed(elapsed: elapsed)
                backgroundDate = nil
            }
        }
    }
    
    func handleBackgroundElapsed(elapsed: Int) {
        var remainingElapsed = elapsed
        while remainingElapsed > 0 {
            if remainingElapsed < timeRemaining {
                timeRemaining -= remainingElapsed
                remainingElapsed = 0
            } else {
                remainingElapsed -= timeRemaining
                currentIndex = (currentIndex + 1) % artworks.count
                timeRemaining = timeLimit
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    nextImage()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func nextImage() {
        if currentIndex < artworks.count - 1 {
            currentIndex += 1
            timeRemaining = timeLimit
        } else {
            // End of session
            stopTimer()
            isPresented = false
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

