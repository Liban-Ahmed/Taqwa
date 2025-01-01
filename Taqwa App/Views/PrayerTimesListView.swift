import SwiftUI

struct PrayerTimesListView: View {
    let prayerTimes: [PrayerTime]
    let currentPrayer: String
    let currentTime: Date
    let selectedDate: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(prayerTimes) { prayer in
                    prayerRow(for: prayer)
                }
            }
            .padding(.horizontal)
        }
    }

    // Separate row rendering logic
    private func prayerRow(for prayer: PrayerTime) -> some View {
        let isToday = Calendar.current.isDateInToday(selectedDate)
        let isPastPrayer = isToday ? (prayer.time < currentTime) : (selectedDate < Date())
        let isCurrentPrayer = isToday && (prayer.name == currentPrayer)

        return HStack {
            Text(prayer.name)
                .font(.headline)
                .foregroundColor(isCurrentPrayer ? .blue : isPastPrayer ? .gray : .primary)
            Spacer()
            Text(prayer.time, formatter: Self.timeFormatter)
                .font(.subheadline)
                .foregroundColor(isPastPrayer ? .gray : .secondary)
            Image(systemName: "bell")
                .foregroundColor(isCurrentPrayer ? .blue : .gray)
        }
        .padding()
        .background(rowBackground(isCurrentPrayer: isCurrentPrayer, isPastPrayer: isPastPrayer))
        .cornerRadius(15)
        .animation(.easeInOut, value: currentPrayer)
        .transition(.scale.combined(with: .opacity))
    }

    // Separate background logic
    private func rowBackground(isCurrentPrayer: Bool, isPastPrayer: Bool) -> some View {
        Group {
            if isCurrentPrayer {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            } else if isPastPrayer {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.1))
            } else {
                Color.clear
            }
        }
    }

    // Date formatter for prayer times
    private static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
