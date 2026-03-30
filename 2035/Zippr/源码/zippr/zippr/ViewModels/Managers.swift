import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    private let key = "favoriteItemIDs"
    @Published var favoriteIDs: Set<String> = []
    
    private init() {
        load()
    }
    
    func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }
    
    func toggle(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        save()
    }
    
    var favoriteItems: [ContentItem] {
        SampleData.items.filter { favoriteIDs.contains($0.id) }
    }
    
    private func save() {
        UserDefaults.standard.setValue(Array(favoriteIDs), forKey: key)
    }
    
    private func load() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        favoriteIDs = Set(saved)
    }
}

class ProgramsManager: ObservableObject {
    static let shared = ProgramsManager()
    
    @Published var enrolledProgramIDs: Set<String> = []
    @Published var completedDaysByProgram: [String: Set<Int>] = [:]
    
    private let enrolledKey = "enrolledPrograms"
    private let completedKey = "completedDays"
    
    private init() { load() }
    
    func isEnrolled(_ id: String) -> Bool { enrolledProgramIDs.contains(id) }
    
    func enroll(_ id: String) {
        enrolledProgramIDs.insert(id)
        save()
    }
    
    func completedDays(for id: String) -> Set<Int> {
        completedDaysByProgram[id] ?? []
    }
    
    func toggleDay(_ day: Int, for programID: String) {
        var days = completedDaysByProgram[programID] ?? []
        if days.contains(day) { days.remove(day) } else { days.insert(day) }
        completedDaysByProgram[programID] = days
        save()
    }
    
    private func save() {
        UserDefaults.standard.setValue(Array(enrolledProgramIDs), forKey: enrolledKey)
        let encodable = completedDaysByProgram.mapValues { Array($0) }
        if let data = try? JSONEncoder().encode(encodable) {
            UserDefaults.standard.setValue(data, forKey: completedKey)
        }
    }
    
    private func load() {
        enrolledProgramIDs = Set(UserDefaults.standard.stringArray(forKey: enrolledKey) ?? [])
        if let data = UserDefaults.standard.data(forKey: completedKey),
           let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            completedDaysByProgram = decoded.mapValues { Set($0) }
        }
    }
}

class WorkoutTimerManager: ObservableObject {
    static let shared = WorkoutTimerManager()
    
    @Published var totalSecondsCompleted: Int = 0
    @Published var workoutStreak: Int = 0
    @Published var lastWorkoutDate: Date?
    
    private let totalKey = "totalSecondsCompleted"
    private let streakKey = "workoutStreak"
    private let lastDateKey = "lastWorkoutDate"
    
    private init() { load() }
    
    func recordWorkout(seconds: Int) {
        totalSecondsCompleted += seconds
        updateStreak()
        save()
    }
    
    var formattedTotal: String {
        let hours = totalSecondsCompleted / 3600
        let minutes = (totalSecondsCompleted % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastWorkoutDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 { workoutStreak += 1 }
            else if diff > 1 { workoutStreak = 1 }
        } else {
            workoutStreak = 1
        }
        lastWorkoutDate = Date()
    }
    
    private func save() {
        UserDefaults.standard.setValue(totalSecondsCompleted, forKey: totalKey)
        UserDefaults.standard.setValue(workoutStreak, forKey: streakKey)
        UserDefaults.standard.setValue(lastWorkoutDate, forKey: lastDateKey)
    }
    
    private func load() {
        totalSecondsCompleted = UserDefaults.standard.integer(forKey: totalKey)
        workoutStreak = UserDefaults.standard.integer(forKey: streakKey)
        lastWorkoutDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date
    }
}
