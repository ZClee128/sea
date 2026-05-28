import SwiftUI
import Combine

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    @Published var timeRemaining: Int = 25 * 60
    @Published var totalTime: Int = 25 * 60
    @Published var isActive: Bool = false
    @Published var selectedMode: TimerMode = .focus
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    
    enum TimerMode: String, CaseIterable, Identifiable {
        case focus, shortBreak, longBreak
        
        var id: String { self.rawValue }
        
        var minutes: Int {
            switch self {
            case .focus: return 25
            case .shortBreak: return 5
            case .longBreak: return 15
            }
        }
        
        var title: String {
            switch self {
            case .focus: return "Focus"
            case .shortBreak: return "S-Break"
            case .longBreak: return "L-Break"
            }
        }
    }
    
    func setMode(_ mode: TimerMode) {
        pause()
        selectedMode = mode
        totalTime = mode.minutes * 60
        timeRemaining = totalTime
    }
    
    func start() {
        if isActive { return }
        isActive = true
        startTime = Date()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func pause() {
        isActive = false
        timer?.cancel()
        timer = nil
    }
    
    func toggle() {
        if isActive {
            pause()
        } else {
            start()
        }
    }
    
    func reset() {
        pause()
        timeRemaining = totalTime
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            complete()
        }
    }
    
    private func complete() {
        pause()
        
        // Log to history
        let sessionName: String
        if selectedMode == .focus {
            if let activeTodo = TodoManager.shared.activeFocusTodo {
                sessionName = activeTodo.title
            } else {
                sessionName = "Focus Session"
            }
        } else {
            sessionName = selectedMode == .shortBreak ? "Short Break" : "Long Break"
        }
        
        HistoryManager.shared.addSession(taskName: sessionName, durationMinutes: selectedMode.minutes)
        
        timeRemaining = totalTime
        
        // Post notification or haptic feedback
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
