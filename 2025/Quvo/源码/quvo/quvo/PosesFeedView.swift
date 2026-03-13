import SwiftUI

struct PosesFeedView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(defaultPoses) { pose in
                        NavigationLink(destination: PoseDetailView(pose: pose)) {
                            PoseCardView(pose: pose)
                        }
                        .buttonStyle(PlainButtonStyle())
                        // Fix for iOS 13 NavigationLink rendering bug
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Fit & Flow", displayMode: .large)
        }
    }
}

struct PoseCardView: View {
    let pose: Pose
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image Header
            Color(.systemGray5)
                .frame(height: 220)
                .overlay(
                    Image(pose.imageName)
                        .resizable()
                        .scaledToFill()
                )
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pose.title)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Targets:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(pose.targetMuscles.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    
                    Text(pose.difficulty)
                        .font(.caption)
                        .padding(4)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
