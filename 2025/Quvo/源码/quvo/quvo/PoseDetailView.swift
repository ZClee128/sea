import SwiftUI

struct PoseDetailView: View {
    let pose: Pose
    @ObservedObject var workoutPlan = UserWorkoutPlan.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Banner Image
                Color(.systemGray5)
                    .frame(height: 350)
                    .overlay(
                        Image(pose.imageName)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text(pose.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            if workoutPlan.isSaved(pose) {
                                workoutPlan.removePose(pose)
                            } else {
                                workoutPlan.savePose(pose)
                            }
                        }) {
                            Image(systemName: workoutPlan.isSaved(pose) ? "star.fill" : "star")
                                .font(.system(size: 22))
                                .foregroundColor(workoutPlan.isSaved(pose) ? .yellow : .blue)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    
                    InfoSection(title: "Difficulty", content: pose.difficulty)
                    InfoSection(title: "Target Muscles", content: pose.targetMuscles.joined(separator: ", "))
                    InfoSection(title: "Benefits", content: pose.benefits)
                    InfoSection(title: "Breathing Guidance", content: pose.breathingTip)
                    
                    Spacer(minLength: 40)
                    
                    Button(action: {
                        if workoutPlan.isSaved(pose) {
                            workoutPlan.removePose(pose)
                        } else {
                            workoutPlan.savePose(pose)
                        }
                    }) {
                        Text(workoutPlan.isSaved(pose) ? "Remove from My Plan" : "Add to My Plan")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(workoutPlan.isSaved(pose) ? Color.red : Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text("Details"), displayMode: .inline)
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
