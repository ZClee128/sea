import Foundation
import Combine

struct DanceMove: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let imageName: String // Placeholder for now
    let description: String
    let technicalTips: [String]
}

class DanceData: ObservableObject {
    @Published var moves: [DanceMove] = [
        DanceMove(title: "Grand Jeté", category: "Ballet", imageName: "Grand Jeté",
                  description: "A large leap in which the legs are thrown 180 degrees.",
                  technicalTips: ["Keep back leg high", "Engage core", "Land softly", "Elongate the neck"]),
        DanceMove(title: "Double Turn", category: "Contemporary", imageName: "Double Turn",
                  description: "A spinning movement on one foot, emphasizing weight shift.",
                  technicalTips: ["Spot your target", "Keep shoulders down", "Snap head", "Maintain vertical axis"]),
        DanceMove(title: "Toprock", category: "Street", imageName: "Toprock",
                  description: "The footwork performed while standing, establishing rhythm.",
                  technicalTips: ["Be bouncy", "Keep eyes on opponent", "Rhythm is key", "Coordinate arm swings"]),
        DanceMove(title: "Pirouette", category: "Ballet", imageName: "Pirouette",
                  description: "A complete turn of the body on one foot.",
                  technicalTips: ["Square hips", "Point toes", "Balance on ball of foot", "Deep plié before start"]),
        DanceMove(title: "Power Move", category: "Street", imageName: "Power Move",
                  description: "Dynamic acro-dance movements requiring raw strength.",
                  technicalTips: ["Momentum is essential", "Strengthen arms", "Protective gear advised", "Focus on rotation speed"]),
        DanceMove(title: "Fluid Flow", category: "Contemporary", imageName: "Fluid Flow",
                  description: "Moving through space with continuous, liquid motion.",
                  technicalTips: ["Breathe through movement", "Release tension", "Explore levels", "Connect sequences"]),
        DanceMove(title: "Arabesque", category: "Ballet", imageName: "Arabesque",
                  description: "A body position supported on one leg with the other extended behind.",
                  technicalTips: ["Straighten the back", "Extend fully to fingertips", "Support leg turnout", "Lift through the chest"]),
        DanceMove(title: "Moonwalk", category: "Street", imageName: "Moonwalk",
                  description: "A dance move where the dancer slides backwards while appearing to walk forward.",
                  technicalTips: ["Weight transition is key", "Smooth floor helps", "Fixed gaze", "Lock the knees at the right moment"]),
        DanceMove(title: "Contract/Release", category: "Contemporary", imageName: "Contract:Release",
                  description: "The Graham technique involving the spine.",
                  technicalTips: ["Exhale on contraction", "Inhale on release", "Center the breath", "Engage abdominal muscles"]),
        DanceMove(title: "Pas de Chat", category: "Ballet", imageName: "Pas de Chat",
                  description: "Step of the cat, a jumping movement.",
                  technicalTips: ["Quick foot lift", "Point toes in air", "Light landing", "Maintain posture"]),
        DanceMove(title: "Body Roll", category: "Street", imageName: "Body Roll",
                  description: "A wave-like motion passing through the body.",
                  technicalTips: ["Isolate body parts", "Start from head or hips", "Practice in mirror", "Keep joints loose"]),
        DanceMove(title: "Floor Work", category: "Contemporary", imageName: "Floor Work",
                  description: "Movements performed low to the ground.",
                  technicalTips: ["Use the floor for leverage", "Weight distribution", "Avoid bruising", "Smooth transitions"])
    ]
}
