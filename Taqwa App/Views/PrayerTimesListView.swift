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
                        isCurrentPrayer: (prayer.name == currentPrayer && Calendar.current.isDateInToday(selectedDate)),
                        isPastPrayer: isPastPrayer(prayer.time),
                        isNextPrayer: isNextPrayer(prayer)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 226/255, green: 230/255, blue: 224/255),
                                Color(red: 216/255, green: 222/255, blue: 210/255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
    }
    
    private func isPastPrayer(_ prayerTime: Date) -> Bool {
        let dayComparison = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day)
        switch dayComparison {
        case .orderedAscending:
            // The selected date is before today: all prayers are past
            return true
        case .orderedSame:
            // Same day: compare exact time
            return prayerTime < currentTime
        case .orderedDescending:
            // Future day: none are past
            return false
        }
    }
    
    private func isNextPrayer(_ prayer: PrayerTime) -> Bool {
        guard Calendar.current.isDateInToday(selectedDate) else {
            return false
        }
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
    @Environment(\.colorScheme) private var colorScheme
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack {
            Text(prayer.name)
                .font(.system(size: 17, weight: getTextWeight()))
                .foregroundColor(getTextColor())
                .dynamicTypeSize(.large)
            
            Spacer()
            
            Text(prayer.time, formatter: PrayerTimeRow.timeFormatter)
                .font(.system(size: 17))
                .foregroundColor(getTimeColor())
                .dynamicTypeSize(.large)
            
            Image(systemName: "bell.fill")
                .font(.system(size: 14))
                .foregroundColor(getBellColor())
                .padding(.leading, 12)
                .opacity(isPastPrayer ? 0.5 : 1.0)
                .onTapGesture {
                    hapticFeedback.impactOccurred()
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(getBackgroundColor())
                .shadow(
                    color: getShadowColor(),
                    radius: isCurrentPrayer || isNextPrayer ? 4 : 2,
                    x: 0,
                    y: colorScheme == .dark ? -1 : 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isCurrentPrayer ? Color.blue.opacity(colorScheme == .dark ? 0.4 : 0.2) : Color.clear,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isCurrentPrayer)
    }
    
    private func getTextWeight() -> Font.Weight {
        if isCurrentPrayer || isNextPrayer {
            return .semibold
        }
        return .regular
    }
    
    private func getTextColor() -> Color {
        if isPastPrayer {
            return colorScheme == .dark ? .gray : .secondary
        }
        if isCurrentPrayer {
            return .blue
        }
        return colorScheme == .dark ? .white : .primary
    }
    
    private func getTimeColor() -> Color {
        if isPastPrayer {
            return colorScheme == .dark ? .gray.opacity(0.8) : .secondary.opacity(0.8)
        }
        if isCurrentPrayer || isNextPrayer {
            return colorScheme == .dark ? .white : .primary
        }
        return colorScheme == .dark ? .gray : .secondary
    }
    
    private func getBellColor() -> Color {
        if isPastPrayer {
            return Color(.systemGray4)
        }
        if isCurrentPrayer {
            return .blue
        }
        return colorScheme == .dark ? Color(.systemGray2) : Color(.systemGray3)
    }
    
    private func getBackgroundColor() -> Color {
        if colorScheme == .dark {
            if isPastPrayer {
                return Color(red: 146/255, green: 163/255, blue: 121/255).opacity(0.97)
            }
            if isCurrentPrayer {
                return Color(.systemGray5).opacity(0.99)
            }
            return Color(red: 146/255, green: 163/255, blue: 121/255)
        } else {
            if isPastPrayer {
                return Color(red: 146/255, green: 163/255, blue: 121/255).opacity(0.97)
            }
            if isCurrentPrayer {
                return Color(.systemGray5).opacity(0.99)
            }
            return Color(red: 146/255, green: 163/255, blue: 121/255)
        }
    }
    
    private func getShadowColor() -> Color {
        if colorScheme == .dark {
            return Color.white.opacity(isCurrentPrayer || isNextPrayer ? 0.05 : 0.02)
        }
        return Color.black.opacity(isCurrentPrayer || isNextPrayer ? 0.08 : 0.04)
    }
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
