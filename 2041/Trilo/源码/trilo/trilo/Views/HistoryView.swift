import SwiftUI

@available(iOS 14.0, *)
struct HistoryView: View {
    @ObservedObject var historyManager = HistoryManager.shared
    
    struct DailyFocus: Identifiable {
        let id = UUID()
        let dayName: String
        let minutes: Int
    }
    
    var weeklyFocusData: [DailyFocus] {
        let calendar = Calendar.current
        var data: [DailyFocus] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Short day name, e.g., Mon, Tue
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let dayName = i == 0 ? "Today" : formatter.string(from: date)
            
            let dailyMinutes = historyManager.sessions
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.durationMinutes }
                
            data.append(DailyFocus(dayName: dayName, minutes: dailyMinutes))
        }
        return data
    }
    
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
                
                // Weekly Bar Chart Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("WEEKLY ANALYTICS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.secondary)
                        .kerning(1.2)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        let data = weeklyFocusData
                        let maxMinutes = max(data.map { $0.minutes }.max() ?? 1, 60)
                        
                        ForEach(data) { dayFocus in
                            VStack(spacing: 6) {
                                Text("\(dayFocus.minutes)m")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(dayFocus.minutes > 0 ? .blue : .secondary.opacity(0.5))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(dayFocus.minutes > 0 ? 
                                          LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom) :
                                          LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.12)]), startPoint: .top, endPoint: .bottom))
                                    .frame(height: CGFloat(dayFocus.minutes) / CGFloat(maxMinutes) * 80 + 5)
                                
                                Text(dayFocus.dayName)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .padding(.bottom, 10)
                
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
