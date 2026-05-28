import SwiftUI

@available(iOS 14.0, *)
struct TimerView: View {
    @ObservedObject var timerManager = TimerManager.shared
    @ObservedObject var historyManager = HistoryManager.shared
    @ObservedObject var audioManager = AudioManager.shared
    @AppStorage("selectedMoodImage") var selectedMoodImage: String = "mood_default"
    @AppStorage("selectedMoodSound") var selectedMoodSound: String = "ambient_library"
    @State private var isBreathing = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image(selectedMoodImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        VStack {
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .clear]), startPoint: .top, endPoint: .center)
                                .frame(height: 250)
                            Spacer()
                        }
                    )
                    .overlay(Color.black.opacity(0.3))
                    .edgesIgnoringSafeArea(.all)
                
                // Use ScrollView to handle short screens
                ScrollView(showsIndicators: false) {
                    VStack(spacing: geometry.size.height > 600 ? 25 : 10) {
                        // Daily Goal Progress
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("DAILY FOCUS GOAL")
                                    .font(.system(size: 11, weight: .black))
                                    .kerning(1.5)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                Spacer()
                                Text("\(historyManager.todayFocusMinutes) / 120 min")
                                    .font(.system(size: 11, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .frame(height: 4)
                                    .foregroundColor(.white.opacity(0.3))
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .frame(width: min(CGFloat(historyManager.todayFocusMinutes) / 120.0 * (min(geometry.size.width, 500) - 60), (min(geometry.size.width, 500) - 60)), height: 4)
                                    .foregroundColor(.blue)
                            }
                            .frame(height: 4)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, geometry.size.height > 600 ? 50 : 30)
                        
                        // Static Title
                        Text("Trilo Focus")
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 5)
                            .lineLimit(1)
                        
                        // Current Focus Task Card (Glassmorphic Material)
                        if #available(iOS 15.0, *) {
                            if let activeTodo = TodoManager.shared.activeFocusTodo {
                                HStack(spacing: 12) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("CURRENT FOCUS TARGET")
                                            .font(.system(size: 9, weight: .black))
                                            .foregroundColor(.blue.opacity(0.8))
                                            .kerning(1.2)
                                        Text(activeTodo.title)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                                .padding(.horizontal, 30)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                            } else {
                                HStack {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("No focus task selected")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(12)
                                .padding(.horizontal, 30)
                            }
                        }
                        
                        // Mode Selectors
                        HStack(spacing: 12) {
                            ForEach(TimerManager.TimerMode.allCases) { mode in
                                Button(action: { timerManager.setMode(mode) }) {
                                    Text(mode.title)
                                        .font(.system(size: 12, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(timerManager.selectedMode == mode ? Color.blue : Color.white.opacity(0.1))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                        // Circular Timer
                        ZStack {
                            // Pulsing Breathing Halo
                            if timerManager.isActive {
                                Circle()
                                    .fill(Color.blue.opacity(0.18))
                                    .scaleEffect(isBreathing ? 1.2 : 0.95)
                                    .blur(radius: isBreathing ? 20 : 8)
                                    .animation(
                                        .easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true),
                                        value: isBreathing
                                    )
                                    .onAppear {
                                        isBreathing = true
                                    }
                                    .onDisappear {
                                        isBreathing = false
                                    }
                            }
                            
                            Circle()
                                .stroke(lineWidth: 6)
                                .opacity(0.2)
                                .foregroundColor(.white)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(timerManager.timeRemaining) / CGFloat(timerManager.totalTime))
                                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                                .foregroundColor(.white)
                                .rotationEffect(Angle(degrees: 270.0))
                                .animation(.linear, value: timerManager.timeRemaining)
                            
                            Text(timeString(time: timerManager.timeRemaining))
                                .font(.system(size: geometry.size.height > 600 ? 64 : 54, weight: .thin, design: .monospaced))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .onLongPressGesture(minimumDuration: 1.5) {
                                    if timerManager.isActive {
                                        timerManager.timeRemaining = 0
                                    }
                                }
                        }
                        .frame(width: min(geometry.size.width * 0.6, geometry.size.height > 600 ? 220 : 180), height: min(geometry.size.width * 0.6, geometry.size.height > 600 ? 220 : 180))
                        .padding(.vertical, 10)
                        
                        // Volume Control
                        VStack(spacing: 5) {
                            HStack(spacing: 10) {
                                Image(systemName: "speaker.fill")
                                Slider(value: $audioManager.volume, in: 0...1)
                                Image(systemName: "speaker.wave.3.fill")
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption2)
                            Text("Ambient Volume")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 40)
                        
                        // Action Buttons
                        HStack(spacing: 40) {
                            Button(action: { 
                                timerManager.toggle()
                                handleAudio()
                            }) {
                                Image(systemName: timerManager.isActive ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            
                            Button(action: { 
                                timerManager.reset()
                                audioManager.stop()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.vertical, 20)
                        
                        // Extra bottom padding to clear TabBar
                        Spacer(minLength: 80)
                    }
                    .frame(width: min(geometry.size.width, 500))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: timerManager.isActive) { active in
            if !active {
                audioManager.stop()
            }
        }
    }
    
    func handleAudio() {
        if timerManager.isActive {
            audioManager.play(sound: selectedMoodSound)
        } else {
            audioManager.stop()
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
