import Foundation
import Combine

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let taskName: String
    let durationMinutes: Int
    let date: Date
}

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var sessions: [FocusSession] = []
    
    private let key = "focus_sessions_history"
    
    var totalFocusMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var todayFocusMinutes: Int {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.date) }
                       .reduce(0) { $0 + $1.durationMinutes }
    }
    
    init() {
        loadSessions()
    }
    
    func addSession(taskName: String, durationMinutes: Int) {
        let newSession = FocusSession(id: UUID(), taskName: taskName, durationMinutes: durationMinutes, date: Date())
        DispatchQueue.main.async {
            self.sessions.insert(newSession, at: 0)
            self.saveSessions()
            self.objectWillChange.send() // Ensure UI updates
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func clearHistory() {
        sessions = []
        UserDefaults.standard.removeObject(forKey: key)
    }
}
