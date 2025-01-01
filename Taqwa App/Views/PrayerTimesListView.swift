import SwiftUI

struct PrayerTimesListView: View {
    let prayerTimes: [PrayerTime]
    let currentPrayer: String
    let currentTime: Date
    let selectedDate: Date
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(prayerTimes) { prayer in
                    PrayerTimeRow(
                        prayer: prayer,
                        isCurrentPrayer: prayer.name == currentPrayer,
                        isPastPrayer: isPastPrayer(prayer.time),
                        isNextPrayer: isNextPrayer(prayer)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGray6))
    }
    
    private func isPastPrayer(_ prayerTime: Date) -> Bool {
        let isToday = Calendar.current.isDateInToday(selectedDate)
        if isToday {
            return prayerTime < currentTime
        } else {
            return selectedDate < Date()
        }
    }
    
    private func isNextPrayer(_ prayer: PrayerTime) -> Bool {
        guard let nextIndex = prayerTimes.firstIndex(where: { !isPastPrayer($0.time) }) else {
            return false
        }
        return prayerTimes[nextIndex].name == prayer.name
    }
}

struct PrayerTimeRow: View {
    let prayer: PrayerTime
    let isCurrentPrayer: Bool
    let isPastPrayer: Bool
    let isNextPrayer: Bool
    
    var body: some View {
        HStack {
            Text(prayer.name)
                .font(.system(size: 17, weight: getTextWeight()))
                .foregroundColor(getTextColor())
            
            Spacer()
            
            Text(prayer.time, formatter: PrayerTimeRow.timeFormatter)
                .font(.system(size: 17))
                .foregroundColor(getTimeColor())
            
            Image(systemName: "bell.fill")
                .font(.system(size: 14))
                .foregroundColor(getBellColor())
                .padding(.leading, 12)
                .opacity(isPastPrayer ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(getBackgroundColor())
                .shadow(
                    color: Color.black.opacity(isCurrentPrayer || isNextPrayer ? 0.08 : 0.04),
                    radius: isCurrentPrayer || isNextPrayer ? 3 : 2,
                    x: 0,
                    y: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isCurrentPrayer ? Color.blue.opacity(0.2) : Color.clear,
                    lineWidth: 1
                )
        )
    }
    
    private func getTextWeight() -> Font.Weight {
        if isCurrentPrayer || isNextPrayer {
            return .semibold
        }
        return .regular
    }
    
    private func getTextColor() -> Color {
        if isPastPrayer {
            return .secondary
        }
        if isCurrentPrayer {
            return .blue
        }
        return .primary
    }
    
    private func getTimeColor() -> Color {
        if isPastPrayer {
            return .secondary.opacity(0.8)
        }
        if isCurrentPrayer || isNextPrayer {
            return .primary
        }
        return .secondary
    }
    
    private func getBellColor() -> Color {
        if isPastPrayer {
            return Color(.systemGray4)
        }
        if isCurrentPrayer {
            return .blue
        }
        return Color(.systemGray3)
    }
    
    private func getBackgroundColor() -> Color {
        if isPastPrayer {
            return Color(.systemBackground).opacity(0.97)
        }
        if isCurrentPrayer {
            return Color(.systemBackground).opacity(0.99)
        }
        return Color(.systemBackground)
    }
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
