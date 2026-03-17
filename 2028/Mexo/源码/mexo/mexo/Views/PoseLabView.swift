import SwiftUI

@available(iOS 14.0, *)
struct PoseLabView: View {
    @State private var selectedCategory: PoseCategory = .standing
    @State private var selectedPose: PoseReference? = nil
    @State private var showingCamera = false
    
    enum PoseCategory: String, CaseIterable, Identifiable {
        case standing = "Standing"
        case sitting = "Sitting"
        case dynamic = "Dynamic"
        case portrait = "Close-up"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .standing: return "person.fill"
            case .sitting: return "person.fill.viewfinder"
            case .dynamic: return "figure.walk"
            case .portrait: return "person.crop.rectangle"
            }
        }
    }
    
    struct PoseReference: Identifiable {
        let id = UUID()
        let category: PoseCategory
        let title: String
        let tips: String
        let image: String // System image or mock asset
    }
    
    let poses: [PoseReference] = [
        PoseReference(category: .standing, title: "The Classic Side-On", tips: "Keep weight on one foot and turn your body 45 degrees away from the camera.", image: "pose_side_on"),
        PoseReference(category: .standing, title: "Over-the-Shoulder", tips: "Look back at the camera while walking away. Creates a sense of mystery.", image: "pose_shoulder"),
        PoseReference(category: .sitting, title: "Relaxed Lean", tips: "Sit on a chair or edge, lean forward slightly with elbows on knees.", image: "pose_relaxed_lean"),
        PoseReference(category: .dynamic, title: "The Mid-Stride", tips: "Capture the moment between steps for a natural, candid look.", image: "pose_mid_stride"),
        PoseReference(category: .portrait, title: "Soft Head Tilt", tips: "Tilt your head slightly to one side to break horizontal lines and add grace.", image: "pose_head_tilt")
    ]
    
    var filteredPoses: [PoseReference] {
        poses.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("PRACTICE / POSE LAB")
                        .font(DesignTokens.Typography.caption())
                        .tracking(4)
                        .foregroundColor(DesignTokens.Colors.accent)
                    
                    Text("Master the Art of Posing")
                        .font(DesignTokens.Typography.title(32))
                        .foregroundColor(DesignTokens.Colors.primary)
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                // Category Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(PoseCategory.allCases) { category in
                            CategoryChip(category: category, isSelected: selectedCategory == category) {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Pose Cards Grid
                VStack(alignment: .leading, spacing: 20) {
                    Text("RECOMMENDED POSES")
                        .font(DesignTokens.Typography.caption())
                        .fontWeight(.heavy)
                        .tracking(2)
                        .foregroundColor(DesignTokens.Colors.secondary)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 20) {
                        ForEach(filteredPoses) { pose in
                            Button(action: { selectedPose = pose }) {
                                PoseReferenceRow(pose: pose)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 120)
            }
        }
        .background(DesignTokens.Colors.background.ignoresSafeArea())
        .sheet(item: $selectedPose) { pose in
            PoseDetailView(pose: pose)
        }
    }
}

@available(iOS 14.0, *)
struct PoseDetailView: View {
    let pose: PoseLabView.PoseReference
    @State private var showingWorkshop = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Large Image Asset
                Image(pose.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 350)
                    .cornerRadius(20)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(pose.title)
                        .font(DesignTokens.Typography.title(24))
                        .foregroundColor(DesignTokens.Colors.primary)
                    
                    Text("EXPERT TIPS")
                        .font(DesignTokens.Typography.caption())
                        .fontWeight(.bold)
                        .foregroundColor(DesignTokens.Colors.accent)
                    
                    Text(pose.tips)
                        .font(DesignTokens.Typography.body(16))
                        .foregroundColor(DesignTokens.Colors.primary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: { showingWorkshop = true }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("START POSING WORKSHOP")
                    }
                    .font(DesignTokens.Typography.headline(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(DesignTokens.Colors.accent)
                    .cornerRadius(15)
                    .shadow(color: DesignTokens.Colors.accent.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(DesignTokens.Colors.background.ignoresSafeArea())
            .navigationBarItems(trailing: Button("Close") { presentationMode.wrappedValue.dismiss() })
            .fullScreenCover(isPresented: $showingWorkshop) {
                let workshopItems = PoseLabView().poses.filter { $0.category == pose.category }.map { 
                    PosingWorkshopView.PoseWorkshopItem(title: $0.title, image: $0.image, tips: $0.tips)
                }
                let startIndex = workshopItems.firstIndex(where: { $0.title == pose.title }) ?? 0
                PosingWorkshopView(poses: workshopItems, startIndex: startIndex)
            }
        }
    }
}

@available(iOS 14.0, *)
struct CategoryChip: View {
    let category: PoseLabView.PoseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                Text(category.rawValue.uppercased())
                    .font(DesignTokens.Typography.caption(10))
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? DesignTokens.Colors.accent : DesignTokens.Colors.surface)
            .foregroundColor(isSelected ? .white : DesignTokens.Colors.primary)
            .cornerRadius(25)
            .shadow(color: isSelected ? DesignTokens.Colors.accent.opacity(0.3) : Color.black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

@available(iOS 14.0, *)
struct PoseReferenceRow: View {
    let pose: PoseLabView.PoseReference
    
    var body: some View {
        HStack(spacing: 20) {
            Image(pose.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(15)
                .clipped()
                .shadow(color: Color.black.opacity(0.05), radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pose.title)
                    .font(DesignTokens.Typography.headline(15))
                    .foregroundColor(DesignTokens.Colors.primary)
                Text(pose.tips)
                    .font(DesignTokens.Typography.body(12))
                    .foregroundColor(DesignTokens.Colors.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignTokens.Colors.slate)
        }
        .padding()
        .background(DesignTokens.Colors.surface)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}
