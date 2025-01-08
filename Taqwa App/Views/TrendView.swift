import SwiftUI

struct TrendView: View {
    @ObservedObject var viewModel: PrayerTimesViewModel
    
    /// Returns the array of Date objects for the current week,
    /// always Monday (weekday = 2) through Sunday.
    private var currentWeek: [Date] {
        var calendar = Calendar.current
        // Force Monday as first weekday
        calendar.firstWeekday = 2
        // Get Monday of this current week
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let mondayOfWeek = calendar.date(from: components) ?? Date()
        
        // Build an array of 7 days from Monday -> Sunday
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: mondayOfWeek)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // 7-day layout with circular progress for each day
            HStack(spacing: 20) {
                ForEach(currentWeek, id: \.self) { day in
                    // Load persisted prayer statuses
                    let dayTimes = viewModel.prayerTimesForDate(day)
                    let dayPrayedCount = dayTimes.filter { $0.status == .prayed }.count
                    let dayProgress = Double(dayPrayedCount) / 5.0
                    let dayInitial = Calendar.current.shortWeekdaySymbols[
                        Calendar.current.component(.weekday, from: day) - 1
                    ].prefix(1)
                    let isToday = Calendar.current.isDateInToday(day)

                    ZStack {
                        CircularProgressView(progress: dayProgress)
                            .frame(width: 32, height: 32)
                        Text(dayInitial)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isToday ? .blue : .primary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 8)
    }
}

struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 6)
                .foregroundColor(Color.gray.opacity(0.2))

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}