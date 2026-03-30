import SwiftUI

@available(iOS 15.0, *)
struct ProgramsView: View {
    @StateObject private var programsManager = ProgramsManager.shared
    @State private var selectedProgram: FitnessProgram? = nil

    @available(iOS 15.0, *)
    var body: some View {
        NavigationView {
            ZStack {
                Color.zBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Stats banner
                        statsBanner
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                        // Programs list
                        Text("All Programs")
                            .font(.zHeadline(18))
                            .foregroundColor(Color.zText)
                            .padding(.horizontal, 16)

                        ForEach(SampleData.programs) { program in
                            Button {
                                selectedProgram = program
                            } label: {
                                ProgramCard(program: program)
                                    .padding(.horizontal, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Programs")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedProgram) { program in
                ProgramDetailSheet(program: program)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var statsBanner: some View {
        HStack(spacing: 0) {
            statCell(value: "\(programsManager.enrolledProgramIDs.count)", label: "Enrolled", icon: "checkmark.circle")
            Divider().frame(height: 40)
            statCell(
                value: "\(programsManager.completedDaysByProgram.values.reduce(0) { $0 + $1.count })",
                label: "Sessions Done",
                icon: "bolt.circle"
            )
            Divider().frame(height: 40)
            statCell(value: WorkoutTimerManager.shared.formattedTotal, label: "Time Trained", icon: "clock")
        }
        .padding(.vertical, 14)
        .background(
            LinearGradient(colors: [Color.zPrimary.opacity(0.08), Color.zAccent.opacity(0.04)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.zPrimary.opacity(0.12), lineWidth: 1)
        )
    }

    private func statCell(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Color.zPrimary)
                .font(.system(size: 16))
            Text(value)
                .font(.zHeadline(18))
                .foregroundColor(Color.zText)
            Text(label)
                .font(.zCaption(10))
                .foregroundColor(Color.zTextSub)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Program Card
@available(iOS 15.0, *)
struct ProgramCard: View {
    let program: FitnessProgram
    @StateObject private var manager = ProgramsManager.shared

    private var completedCount: Int {
        manager.completedDays(for: program.id).count
    }
    private var progress: Double {
        Double(completedCount) / Double(program.sessionsCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // overlay pattern — Color frame cannot be stretched by image
                Color.zPrimary.opacity(0.3)
                    .overlay(
                        Image(program.title)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    )
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(16, corners: [.topLeft, .topRight])

                LinearGradient(colors: [.clear, Color.black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                    .frame(height: 160)
                    .cornerRadius(16, corners: [.topLeft, .topRight])

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        DifficultyBadge(level: program.level)
                        Spacer()
                        if manager.isEnrolled(program.id) {
                            Label("Enrolled", systemImage: "checkmark.circle.fill")
                                .font(.zCaption(11))
                                .foregroundColor(Color(hex: "#4CAF50"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    }
                    Text(program.title)
                        .font(.zHeadline(16))
                        .foregroundColor(.white)
                    HStack(spacing: 8) {
                        Label(program.duration, systemImage: "calendar")
                        Label("\(program.sessionsCount) sessions", systemImage: "list.number")
                    }
                    .font(.zCaption(11))
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(12)
            }

            // Progress bar
            if manager.isEnrolled(program.id) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(completedCount)/\(program.sessionsCount) sessions")
                            .font(.zCaption(12))
                            .foregroundColor(Color.zTextSub)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.zCaption(12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.zPrimary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.zDivider)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * CGFloat(progress), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.zPrimary.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Program Detail Sheet
@available(iOS 15.0, *)
struct ProgramDetailSheet: View {
    let program: FitnessProgram
    @StateObject private var manager = ProgramsManager.shared
    @Environment(\.presentationMode) var presentationMode

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        NavigationView {
            ZStack {
                Color.zBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Cover
                        // Cover — overlay pattern prevents AsyncImage from stretching
                        Color.zCardBg
                            .overlay(
                                Image(program.title)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            )
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(20)
                            .padding(.horizontal, 16)

                        // Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(program.title)
                                .font(.zTitle(24))
                                .foregroundColor(Color.zText)
                            Text(program.description)
                                .font(.zBody(14))
                                .foregroundColor(Color.zTextSub)
                                .lineSpacing(4)

                            HStack(spacing: 16) {
                                Label(program.duration, systemImage: "calendar").font(.zCaption(13))
                                Label("\(program.sessionsCount) sessions", systemImage: "list.number").font(.zCaption(13))
                                DifficultyBadge(level: program.level)
                            }
                            .foregroundColor(Color.zTextSub)
                        }
                        .padding(.horizontal, 16)

                        // Enrollment button
                        if !manager.isEnrolled(program.id) {
                            Button {
                                withAnimation { manager.enroll(program.id) }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Enroll in Program")
                                        .font(.zHeadline(16))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                                                          startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(14)
                                .shadow(color: Color.zPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 16)
                        }

                        // Day tracker
                        if manager.isEnrolled(program.id) {
                            dayTrackerSection
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(program.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(Color.zPrimary))
        }
    }

    private var dayTrackerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Tracker")
                .font(.zHeadline(16))
                .foregroundColor(Color.zText)
                .padding(.horizontal, 16)

            Text("Tap a day to mark it complete")
                .font(.zBody(12))
                .foregroundColor(Color.zTextSub)
                .padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...program.sessionsCount, id: \.self) { day in
                    let done = manager.completedDays(for: program.id).contains(day)
                    Button {
                        withAnimation(.spring()) { manager.toggleDay(day, for: program.id) }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(done
                                    ? LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.zDivider, Color.zDivider],
                                                     startPoint: .top, endPoint: .bottom))

                            if done {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(day)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color.zTextSub)
                            }
                        }
                        .frame(width: 36, height: 36)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
