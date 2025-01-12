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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.30),
                    Color(red: 0.50, green: 0.25, blue: 0.60)
                ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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
    @State private var showNotificationOptions = false
        
    private var notificationKey: String {
        return "\(selectedDate)-\(prayer.name)-notification"
    }
    // Initialize with prayer's notification option instead of .standard
        @State private var currentNotificationOption: NotificationOption
        
        // Add initializer to set initial state
        init(prayer: Binding<PrayerTime>, isCurrentPrayer: Bool, isPastPrayer: Bool, isNextPrayer: Bool, selectedDate: Date, savePrayerState: @escaping () -> Void) {
            self._prayer = prayer
            self.isCurrentPrayer = isCurrentPrayer
            self.isPastPrayer = isPastPrayer
            self.isNextPrayer = isNextPrayer
            self.selectedDate = selectedDate
            self.savePrayerState = savePrayerState
            // Initialize with prayer's current notification option
            self._currentNotificationOption = State(initialValue: prayer.wrappedValue.notificationOption)
        }
    private func saveNotificationOption() {
            UserDefaults.standard.set(currentNotificationOption.rawValue, forKey: notificationKey)
            UserDefaults.standard.synchronize() // Force synchronize
            prayer.notificationOption = currentNotificationOption // Update model
            scheduleNotification() // Update notification
        }
    private func loadNotificationOption() {
            if let savedOption = UserDefaults.standard.string(forKey: notificationKey),
               let option = NotificationOption(rawValue: savedOption) {
                currentNotificationOption = option // Update local state
                prayer.notificationOption = option // Update model
            }
        }
    
    var body: some View {
        Button(action: {
                    hapticFeedback.impactOccurred()
                    prayer.status = prayer.status.nextStatus()
                    savePrayerStatus()
                    savePrayerState()
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
                
                Menu {
                            ForEach(NotificationOption.allCases, id: \.self) { option in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        currentNotificationOption = option
                                        prayer.notificationOption = option
                                        saveNotificationOption() // Save when changed
                                    }
                                }) {
                                           HStack {
                                               Image(systemName: option.icon)
                                                   .foregroundColor(option.color)
                                               VStack(alignment: .leading) {
                                                   Text(option.rawValue)
                                                   Text(option.description)
                                                       .font(.caption)
                                                       .foregroundColor(.secondary)
                                               }
                                               Spacer()
                                               if currentNotificationOption == option {
                                                   Image(systemName: "circle.inset.filled")
                                                       .foregroundColor(option.color)
                                               }
                                           }
                                       }
                                   }
                               } label: {
                                   Image(systemName: currentNotificationOption.icon)
                                       .font(.system(size: 14))
                                       .foregroundColor(currentNotificationOption.color)
                                       .padding(.leading, 12)
                                       .opacity(isPastPrayer ? 0.5 : 1.0)
                               }
                           }            .padding(.horizontal, 16)
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
                   loadNotificationOption() // Load on appear
                   currentNotificationOption = prayer.notificationOption // Sync state
               }
               .onChange(of: prayer.notificationOption) { newValue in
                   currentNotificationOption = newValue // Keep local state in sync
                   saveNotificationOption() // Save when changed externally
               }
        
    }
    
    private func savePrayerStatus() {
        UserDefaults.standard.set(prayer.status.rawValue, forKey: userDefaultsKey)
    }
    
    private func loadPrayerStatus() {
        if let savedStatus = UserDefaults.standard.string(forKey: userDefaultsKey),
           let status = PrayerStatus(rawValue: savedStatus) {
            prayer.status = status
        } else {
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
                return Color.blue.opacity(0.15).opacity(0.97)
            }
            if isCurrentPrayer {
                return Color.blue.opacity(0.15).opacity(0.99)
            }
            return Color.blue.opacity(0.15)
        } else {
            if isPastPrayer {
                return Color.blue.opacity(0.15).opacity(0.97)
            }
            if isCurrentPrayer {
                return Color.blue.opacity(0.15).opacity(0.99)
            }
            return Color.blue.opacity(0.15)
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
        
    
        
    private func scheduleNotification() {
            let identifier = "\(prayer.name)-\(Calendar.current.startOfDay(for: prayer.time))"
            
            Task { @MainActor in
                // Remove existing notifications
                await UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                
                // Don't schedule if silent
                guard prayer.notificationOption != .silent else { return }
                
                let content = UNMutableNotificationContent()
                content.title = "\(prayer.name)"
                content.body = "It's time for \(prayer.name)"
                
                // Set sound based on option
                switch prayer.notificationOption {
                case .silent:
                    return
                case .standard:
                    content.sound = .default
                case .adhan:
                    if let soundPath = Bundle.main.path(forResource: "prayerCall", ofType: "mp3") {
                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundPath))
                    } else {
                        print("Warning: prayerCall.mp3 not found in bundle")
                        content.sound = .default
                    }
                }
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: prayer.time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                do {
                    try await UNUserNotificationCenter.current().add(request)
                    print("Successfully scheduled notification for \(self.prayer.name)")
                } catch {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
        
    
    
}
