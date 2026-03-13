import Foundation
import Combine

struct Pose: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let targetMuscles: [String]
    let benefits: String
    let breathingTip: String
    let difficulty: String
    let imageName: String
}

class UserWorkoutPlan: ObservableObject {
    static let shared = UserWorkoutPlan()
    @Published var savedPoses: [Pose] = []
    @Published var completedPoseIDs: Set<String> = []
    
    private init() {
        loadPoses()
        loadCompletedState()
        checkDailyReset()
    }
    
    func savePose(_ pose: Pose) {
        if !savedPoses.contains(where: { $0.id == pose.id }) {
            savedPoses.append(pose)
            saveToDisk()
        }
    }
    
    func removePose(_ pose: Pose) {
        savedPoses.removeAll(where: { $0.id == pose.id })
        completedPoseIDs.remove(pose.id)
        saveToDisk()
        saveCompletedState()
    }
    
    func isSaved(_ pose: Pose) -> Bool {
        savedPoses.contains(where: { $0.id == pose.id })
    }
    
    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(savedPoses) {
            UserDefaults.standard.set(data, forKey: "savedWorkoutPlan")
        }
    }
    
    private func loadPoses() {
        if let data = UserDefaults.standard.data(forKey: "savedWorkoutPlan"),
           let poses = try? JSONDecoder().decode([Pose].self, from: data) {
            self.savedPoses = poses
        }
    }
    
    // MARK: - Daily Tracking Logic
    func toggleCompletion(for pose: Pose) {
        if completedPoseIDs.contains(pose.id) {
            completedPoseIDs.remove(pose.id)
        } else {
            completedPoseIDs.insert(pose.id)
        }
        saveCompletedState()
    }
    
    private func saveCompletedState() {
        let array = Array(completedPoseIDs)
        UserDefaults.standard.set(array, forKey: "completedPoseIDs")
    }
    
    private func loadCompletedState() {
        if let array = UserDefaults.standard.stringArray(forKey: "completedPoseIDs") {
            self.completedPoseIDs = Set(array)
        }
    }
    
    func checkDailyReset() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let todayString = formatter.string(from: Date())
        
        let lastDateString = UserDefaults.standard.string(forKey: "last_completion_date") ?? ""
        if lastDateString != todayString {
            // It's a new day, reset progress and reward state
            completedPoseIDs.removeAll()
            UserDefaults.standard.set(todayString, forKey: "last_completion_date")
            UserDefaults.standard.set(false, forKey: "daily_reward_claimed")
            saveCompletedState()
        }
    }
}

let defaultPoses: [Pose] = [
    Pose(title: "Downward Facing Dog", targetMuscles: ["Hamstrings", "Calves", "Shoulders"], benefits: "Stretches the entire back body, strengthens the upper body.", breathingTip: "Inhale as you lift your hips, exhale as you press heels down.", difficulty: "Beginner", imageName: "Downward Facing Dog"),
    Pose(title: "Warrior II", targetMuscles: ["Quads", "Glutes", "Core"], benefits: "Builds strength and stamina, opens hips and chest.", breathingTip: "Inhale to expand the chest, exhale into the lunge.", difficulty: "Beginner", imageName: "Warrior II"),
    Pose(title: "Tree Pose", targetMuscles: ["Ankles", "Core"], benefits: "Improves balance and focus.", breathingTip: "Breathe deeply and find a focal point.", difficulty: "Beginner", imageName: "Tree Pose"),
    Pose(title: "Cobra Pose", targetMuscles: ["Spine", "Chest"], benefits: "Strengthens the spine, stretches chest and lungs.", breathingTip: "Inhale as you lift your chest, exhale to release.", difficulty: "Intermediate", imageName: "Cobra Pose"),
    Pose(title: "Pigeon Pose", targetMuscles: ["Hip Flexors", "Glutes"], benefits: "Deeply opens hip joints, stretches thighs.", breathingTip: "Breathe into the tightness in the hip.", difficulty: "Intermediate", imageName: "Pigeon Pose"),
    Pose(title: "Plank Pose", targetMuscles: ["Core", "Shoulders", "Arms"], benefits: "Builds core strength and stability.", breathingTip: "Steady breath, keeping the body in a straight line.", difficulty: "Beginner", imageName: "Plank Pose"),
    Pose(title: "Camel Pose", targetMuscles: ["Chest", "Abdomen", "Quads"], benefits: "Stretches the front of the body, improves posture.", breathingTip: "Inhale to lift the chest, exhale to arch back.", difficulty: "Intermediate", imageName: "Camel Pose"),
    Pose(title: "Bridge Pose", targetMuscles: ["Glutes", "Lower Back", "Neck"], benefits: "Strengthens the back and glutes, relieves tension.", breathingTip: "Inhale as you lift hips, exhale as you lower.", difficulty: "Beginner", imageName: "Bridge Pose"),
    Pose(title: "Child's Pose", targetMuscles: ["Lower Back", "Hips", "Thighs"], benefits: "Gently stretches the lower back, calming the mind.", breathingTip: "Breathe deeply into the back of your ribs.", difficulty: "Beginner", imageName: "Child's Pose"),
    Pose(title: "Boat Pose", targetMuscles: ["Core", "Hip Flexors", "Spine"], benefits: "Strengthens the abdomen, hip flexors, and spine.", breathingTip: "Inhale to lengthen the spine, exhale to hold the pose.", difficulty: "Intermediate", imageName: "Boat Pose"),
    Pose(title: "Triangle Pose", targetMuscles: ["Hamstrings", "Hips", "Groin"], benefits: "Stretches legs and torso, mobilizes hips.", breathingTip: "Inhale to reach forward, exhale to lower the hand.", difficulty: "Beginner", imageName: "Triangle Pose")
]
