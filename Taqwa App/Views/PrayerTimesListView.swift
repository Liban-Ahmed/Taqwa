import SwiftUI

struct PrayerTimesListView: View {
    @ObservedObject var viewModel: PrayerTimesViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.prayerTimes.indices, id: \.self) { index in
                    PrayerTimeRow(
                        prayer: $viewModel.prayerTimes[index],
                        isCurrentPrayer: (viewModel.prayerTimes[index].name == viewModel.currentPrayer && Calendar.current.isDateInToday(viewModel.selectedDate)),
                        isPastPrayer: isPastPrayer(viewModel.prayerTimes[index].time),
                        isNextPrayer: isNextPrayer(viewModel.prayerTimes[index]),
                        selectedDate: viewModel.selectedDate,
                        savePrayerState: { viewModel.savePrayerState(for: viewModel.prayerTimes[index]) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGray6))
    }
    
    private func isPastPrayer(_ prayerTime: Date) -> Bool {
        let dayComparison = Calendar.current.compare(viewModel.selectedDate, to: Date(), toGranularity: .day)
        switch dayComparison {
        case .orderedAscending:
            // The selected date is before today: all prayers are past
            return true
        case .orderedSame:
            // Same day: compare exact time
            return prayerTime < Date()
        case .orderedDescending:
            // Future day: none are past
            return false
        }
    }
    
    private func isNextPrayer(_ prayer: PrayerTime) -> Bool {
        guard Calendar.current.isDateInToday(viewModel.selectedDate) else {
            return false
        }
        guard let nextIndex = viewModel.prayerTimes.firstIndex(where: { !isPastPrayer($0.time) }) else {
            return false
        }
        return viewModel.prayerTimes[nextIndex].name == prayer.name
    }
}

struct PrayerTimeRow: View {
    @Binding var prayer: PrayerTime
    let isCurrentPrayer: Bool
    let isPastPrayer: Bool
    let isNextPrayer: Bool
    let selectedDate: Date
    let savePrayerState: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    private var userDefaultsKey: String {
        return "\(selectedDate)-\(prayer.name)"
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback.impactOccurred()
            prayer.status = prayer.status.nextStatus()
            savePrayerStatus()
            savePrayerState()
            print("Tapped \(prayer.name), new status: \(prayer.status.rawValue)")
        }) {
            HStack {
                // Circle with checkmark or other icon based on prayer status
                Image(systemName: prayer.status.iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(prayer.status.iconColor)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(prayer.status.backgroundColor))
                
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
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadPrayerStatus()
        }
    }
    
    private func savePrayerStatus() {
        UserDefaults.standard.set(prayer.status.rawValue, forKey: userDefaultsKey)
        print("Saved \(prayer.name) status: \(prayer.status.rawValue) for date: \(selectedDate)")
    }
    
    private func loadPrayerStatus() {
        if let savedStatus = UserDefaults.standard.string(forKey: userDefaultsKey),
           let status = PrayerStatus(rawValue: savedStatus) {
            prayer.status = status
            print("Loaded \(prayer.name) status: \(status.rawValue) for date: \(selectedDate)")
        } else {
            print("No saved status for \(prayer.name) on date: \(selectedDate)")
        }
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
                return Color(.systemGray6).opacity(0.97)
            }
            if isCurrentPrayer {
                return Color(.systemGray5).opacity(0.99)
            }
            return Color(.systemGray6)
        } else {
            if isPastPrayer {
                return Color(.systemBackground).opacity(0.97)
            }
            if isCurrentPrayer {
                return Color(.systemBackground).opacity(0.99)
            }
            return Color(.systemBackground)
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