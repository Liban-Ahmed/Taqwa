import SwiftUI

struct PrayerTimesListView: View {
    let prayerTimes: [PrayerTime]
    let currentPrayer: String

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
        let isCurrentPrayer = prayer.name == currentPrayer

        return HStack {
            Text(prayer.name)
                .font(.headline)
                .foregroundColor(isCurrentPrayer ? .blue : .primary)
            Spacer()
            Text(prayer.time, formatter: Self.timeFormatter)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Image(systemName: "bell")
                .foregroundColor(.gray)
        }
        .padding()
        .background(rowBackground(isCurrentPrayer: isCurrentPrayer))
        .cornerRadius(15)
        .animation(.easeInOut, value: currentPrayer)
        .transition(.scale.combined(with: .opacity))
    }

    // Separate background logic
    private func rowBackground(isCurrentPrayer: Bool) -> some View {
        Group {
            if isCurrentPrayer {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
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
