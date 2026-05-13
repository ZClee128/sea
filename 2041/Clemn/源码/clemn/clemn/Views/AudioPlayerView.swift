import SwiftUI
import Combine

@available(iOS 14.0, *)
struct AudioPlayerView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var timeRemaining = 25 * 60 // 25 minutes
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let tracks = [
        ("Professional Studio", "studio"),
        ("Nature Focus", "nature"),
        ("Coffee Shop", "cafe"),
        ("White Noise", "white")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemGray6)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 25) {
                        HStack {
                            Text("Studio Ambience")
                                .font(.system(size: 28, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 60)
                        
                        VStack(spacing: 5) {
                            Text(timeString(time: timeRemaining))
                                .font(.system(size: 48, weight: .light, design: .monospaced))
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 20) {
                                Button(action: { isTimerRunning.toggle() }) {
                                    Text(isTimerRunning ? "Pause Timer" : "Start Focus")
                                        .font(.caption2)
                                        .bold()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                
                                Button(action: {
                                    isTimerRunning = false
                                    timeRemaining = 25 * 60
                                }) {
                                    Text("Reset")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onReceive(timer) { _ in
                            if isTimerRunning && timeRemaining > 0 {
                                timeRemaining -= 1
                            }
                        }
                        
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 200, height: 200)
                            
                            HStack(alignment: .center, spacing: 6) {
                                ForEach(0..<10) { i in
                                    VisualizerBar(isPlaying: audioManager.isPlaying)
                                }
                            }
                        }
                        .frame(height: 220)
                        
                        VStack(spacing: 8) {
                            Text(audioManager.currentTrackName ?? "No Track Selected")
                                .font(.system(size: 22, weight: .bold))
                            
                            Text(audioManager.isPlaying ? "Now Playing..." : "Select a track to begin focus")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(tracks, id: \.1) { track in
                                    let isSelected = audioManager.currentTrackName == track.0
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            audioManager.playTrack(name: track.0, fileName: track.1)
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            if isSelected && audioManager.isPlaying {
                                                Image(systemName: "waveform")
                                                    .font(.system(size: 12))
                                            }
                                            Text(track.0)
                                                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(isSelected ? Color.blue : Color.white)
                                        .foregroundColor(isSelected ? .white : .blue)
                                        .cornerRadius(25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                        .scaleEffect(isSelected ? 1.05 : 1.0)
                                        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .frame(height: 80)
                        
                        HStack(spacing: 50) {
                            Button(action: { audioManager.stop() }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 28))
                                    Text("Stop")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(.red.opacity(0.8))
                            }
                            
                            Button(action: { audioManager.togglePlayPause() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
    }
}

func timeString(time: Int) -> String {
    let minutes = time / 60
    let seconds = time % 60
    return String(format: "%02d:%02d", minutes, seconds)
}


@available(iOS 14.0, *)
struct VisualizerBar: View {
    let isPlaying: Bool
    @State private var height: CGFloat = 20
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.blue)
            .frame(width: 5, height: height)
            .onReceive(timer) { _ in
                if isPlaying {
                    withAnimation(.linear(duration: 0.1)) {
                        height = CGFloat.random(in: 30...90)
                    }
                } else {
                    withAnimation(.linear(duration: 0.2)) {
                        height = 10
                    }
                }
            }
    }
}
