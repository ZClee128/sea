import SwiftUI
import Combine

struct PracticeTimerView: View {
    @State private var timeRemaining = 60
    @State private var isActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let presets = [30, 60, 120, 300]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Timer Ring
                ZStack {
                    Circle()
                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / 60.0)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear)
                    
                    VStack {
                        Text("\(timeString(time: timeRemaining))")
                            .font(.system(size: 64, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                        Text("REMAINING")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 250, height: 250)
                
                // Presets
                HStack(spacing: 15) {
                    ForEach(presets, id: \.self) { seconds in
                        Button(action: {
                            timeRemaining = seconds
                            isActive = false
                        }) {
                            if #available(iOS 14.0, *) {
                                Text("\(seconds)s")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                }
                
                // Controls
                HStack(spacing: 40) {
                    Button(action: {
                        isActive.toggle()
                    }) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        timeRemaining = 60
                        isActive = false
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.primary)
                            .frame(width: 60, height: 60)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Practice Timer", displayMode: .inline)
            .onReceive(timer) { _ in
                guard isActive else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    isActive = false
                }
            }
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
