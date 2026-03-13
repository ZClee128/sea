import SwiftUI

struct MyPlanView: View {
    @ObservedObject var workoutPlan = UserWorkoutPlan.shared
    @ObservedObject var appState = AppState.shared
    
    @State private var showRewardAlert = false
    
    var progress: Double {
        if workoutPlan.savedPoses.isEmpty { return 0 }
        return Double(workoutPlan.completedPoseIDs.count) / Double(workoutPlan.savedPoses.count)
    }
    
    var allCompleted: Bool {
        !workoutPlan.savedPoses.isEmpty && workoutPlan.completedPoseIDs.count == workoutPlan.savedPoses.count
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if workoutPlan.savedPoses.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "figure.mind.and.body")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Your plan is empty")
                            .font(.system(size: 22, weight: .bold))
                        Text("Browse poses and add them to your plan to build a daily routine.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    // Daily Progress Header
                    VStack {
                        HStack {
                            Text("Daily Progress")
                                .font(.headline)
                            Spacer()
                            Text("\(workoutPlan.completedPoseIDs.count) / \(workoutPlan.savedPoses.count)")
                                .fontWeight(.bold)
                                .foregroundColor(allCompleted ? .green : .blue)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 12)
                                    .opacity(0.3)
                                    .foregroundColor(Color.gray)
                                
                                Rectangle()
                                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: 12)
                                    .foregroundColor(allCompleted ? .green : .blue)
                                    .animation(.linear)
                            }
                            .cornerRadius(6)
                        }
                        .frame(height: 12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .background(Color(.systemGray6))
                    
                    List {
                        ForEach(workoutPlan.savedPoses) { pose in
                            HStack(spacing: 15) {
                                // Completion Checkmark
                                Button(action: {
                                    workoutPlan.toggleCompletion(for: pose)
                                    checkReward()
                                }) {
                                    Image(systemName: workoutPlan.completedPoseIDs.contains(pose.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(workoutPlan.completedPoseIDs.contains(pose.id) ? .green : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                NavigationLink(destination: PoseDetailView(pose: pose)) {
                                    HStack(spacing: 15) {
                                        Image(pose.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .background(Color(.systemGray5))
                                            .cornerRadius(8)
                                            .clipped()
                                            
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(pose.title).font(.headline)
                                            Text(pose.difficulty).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: deletePose)
                    }
                }
            }
            .navigationBarTitle("My Plan", displayMode: .inline)
            .alert(isPresented: $showRewardAlert) {
                Alert(
                    title: Text("🎊 Awesome Job!"),
                    message: Text("You completed your daily routine. Here are 10 Coins as a reward!"),
                    dismissButton: .default(Text("Claim")) {
                        appState.coinBalance += 10
                        UserDefaults.standard.set(true, forKey: "daily_reward_claimed")
                    }
                )
            }
            .onAppear {
                workoutPlan.checkDailyReset() // check logic
            }
        }
    }
    
    private func checkReward() {
        if allCompleted {
            let alreadyClaimed = UserDefaults.standard.bool(forKey: "daily_reward_claimed")
            if !alreadyClaimed {
                showRewardAlert = true
            }
        }
    }
    
    func deletePose(at offsets: IndexSet) {
        let posesToRemove = offsets.map { workoutPlan.savedPoses[$0] }
        for pose in posesToRemove {
            workoutPlan.removePose(pose)
        }
    }
}
