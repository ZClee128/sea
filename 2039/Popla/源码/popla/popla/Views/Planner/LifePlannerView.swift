import SwiftUI

@available(iOS 14.0, *)
struct LifePlannerView: View {
    @ObservedObject var collectionManager = CollectionManager.shared
    
    // Use shared data source
    let allMoments = MomentsData.all
    
    var savedItems: [UrbanMoment] {
        allMoments.filter { collectionManager.isSaved($0.title) }
    }
    
    @State private var checklist = [
        PlannerItem(title: "Pick up new vinyl at Archive", isCompleted: false),
        PlannerItem(title: "Draft editorial for Street Pulse", isCompleted: true)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 35) {
                        headerSection
                        
                        // 1. Progress Section (Gamification)
                        progressSection
                        
                        // 2. My Board Section (Saved Moments)
                        boardSection
                        
                        // 3. My Contributions Section
                        if !collectionManager.contributedSpots.isEmpty {
                            contributionsSection
                        }
                        
                        // 4. Curated Route Section (Procedural Art - NO BLANKS)
                        routeSection
                        
                        // 5. Activity Checklist
                        tasksSection
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Critical for stable navigation
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("DISCOVERY")
                .font(.system(size: 10, weight: .black))
                .tracking(5)
                .foregroundColor(.gray.opacity(0.4))
            Text("Daily Board")
                .font(.system(size: 34, weight: .black))
        }
        .padding(.horizontal, 30)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("CURATOR LEVEL").font(.system(size: 10, weight: .black)).foregroundColor(.gray)
                Spacer()
                Text("\(Int(collectionManager.curatorProgress * 100))% EXP").font(.system(size: 10, weight: .bold))
            }
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.1)).frame(height: 6)
                Capsule().fill(Color.black).frame(width: 330 * CGFloat(collectionManager.curatorProgress), height: 6)
            }
            Text("Explore and check tasks to unlock new urban routes.")
                .font(.system(size: 11, weight: .medium)).foregroundColor(.gray.opacity(0.6))
        }
        .padding(.horizontal, 30)
    }
    
    private var boardSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("MY SAVED MOMENTS").font(.system(size: 12, weight: .black)).foregroundColor(.gray.opacity(0.5))
                Spacer()
                Text("\(savedItems.count) ITEMS").font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 30)
            
            if savedItems.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.2))
                    Text("Collect moments in Explore to build your board.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(Color.gray.opacity(0.03))
                .cornerRadius(25)
                .padding(.horizontal, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(savedItems) { moment in
                            NavigationLink(destination: DetailView(moment: moment)) {
                                VStack(alignment: .leading) {
                                    Image(moment.title)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                                    Text(moment.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
    }
    
    private var contributionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("MY CONTRIBUTIONS").font(.system(size: 12, weight: .black)).foregroundColor(.gray.opacity(0.5))
                .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(collectionManager.contributedSpots) { spot in
                        NavigationLink(destination: ContributionDetailView(spot: spot)) {
                            VStack(alignment: .leading, spacing: 10) {
                                ZStack {
                                    if let data = spot.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.gray.opacity(0.05)
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                }
                                .frame(width: 140, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(spot.title).font(.system(size: 13, weight: .bold))
                                    Text(spot.category).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 30)
            }
        }
    }
    
    private var routeSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("URBAN ROUTE PLANNER").font(.system(size: 12, weight: .black)).foregroundColor(.gray.opacity(0.5))
            
            NavigationLink(destination: RouteDetailView()) {
                ZStack(alignment: .bottomLeading) {
                    // Procedural Art
                    ProceduralBauhausView()
                        .frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 35))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("SATURDAY RHYTHM")
                            .font(.system(size: 10, weight: .black))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.white).cornerRadius(5)
                        Text("The Bauhaus Walk")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.black)
                    }
                    .padding(25)
                    .background(Color.white.opacity(0.7).blur(radius: 20))
                    .cornerRadius(20)
                    .padding(30)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 30)
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ACTIVITY CHECKLIST").font(.system(size: 12, weight: .black)).foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 15) {
                ForEach(collectionManager.checklist) { task in
                    Button(action: { 
                        collectionManager.toggleTask(task.id)
                    }) {
                        TaskRow(title: task.title, isDone: task.isCompleted)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 30)
    }
}

/// A procedural art view to guarantee zero blank spaces in the UI.
struct ProceduralBauhausView: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
            
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 200, height: 200)
                .offset(x: 100, y: -50)
            
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 150, height: 300)
                .rotationEffect(.degrees(45))
                .offset(x: -80, y: 100)
                
            VStack(spacing: 20) {
                ForEach(0..<10) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                }
            }
            .padding(40)
            
            // Abstract Route Path
            Path { path in
                path.move(to: CGPoint(x: 50, y: 50))
                path.addLine(to: CGPoint(x: 150, y: 100))
                path.addQuadCurve(to: CGPoint(x: 250, y: 200), control: CGPoint(x: 200, y: 0))
                path.addLine(to: CGPoint(x: 50, y: 250))
            }
            .stroke(Color.black, lineWidth: 2)
            .opacity(0.3)
        }
    }
}

struct TaskRow: View {
    let title: String
    let isDone: Bool
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().stroke(Color.black, lineWidth: 1.5).frame(width: 22, height: 22)
                if isDone {
                    Image(systemName: "checkmark").font(.system(size: 10, weight: .bold))
                }
            }
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .strikethrough(isDone)
                .opacity(isDone ? 0.3 : 1.0)
            Spacer()
        }
        .padding(20)
        .background(isDone ? Color.black.opacity(0.02) : Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct LifePlannerView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            LifePlannerView()
        } else {
            // Fallback on earlier versions
        }
    }
}
