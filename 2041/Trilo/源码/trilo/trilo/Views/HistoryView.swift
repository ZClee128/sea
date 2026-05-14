import SwiftUI

@available(iOS 14.0, *)
struct HistoryView: View {
    @ObservedObject var historyManager = HistoryManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics Summary
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        StatCard(title: "Total Time", value: "\(historyManager.totalFocusMinutes)m", icon: "clock.fill", color: .blue)
                        StatCard(title: "Today", value: "\(historyManager.todayFocusMinutes)m", icon: "bolt.fill", color: .orange)
                        StatCard(title: "Sessions", value: "\(historyManager.totalSessions)", icon: "checkmark.circle.fill", color: .green)
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                List {
                    if historyManager.sessions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No focus sessions yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Start a timer to record your progress.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .listRowBackground(Color.clear)
                    } else {
                        Section(header: Text("Recent Sessions")) {
                            ForEach(historyManager.sessions) { session in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(session.taskName)
                                            .font(.headline)
                                        Text(formatDate(session.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("\(session.durationMinutes)m")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Section {
                            Button(action: {
                                historyManager.clearHistory()
                            }) {
                                Text("Clear History")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Focus History")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 110, height: 110)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
