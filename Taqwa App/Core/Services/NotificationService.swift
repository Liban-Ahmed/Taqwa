//
//  NotificationService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let prayerCalculationService = PrayerCalculationService()
    
    func scheduleNotificationsForNextDay() {
        // Clear old notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Get tomorrow's date
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Get location from LocationManager
        guard let location = LocationManager().lastKnownLocation else { return }
        
        // Get prayer times for tomorrow
        let prayerTimes = prayerCalculationService.getPrayerTimes(
            location: (location.coordinate.latitude, location.coordinate.longitude),
            date: tomorrow
        )
        
        // Schedule notifications for each prayer
        for prayer in prayerTimes.times {
            scheduleNotification(for: prayer, on: tomorrow)
        }
    }
    
    private func scheduleNotification(for prayer: PrayerTime, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = prayer.name
        content.body = "It's time for \(prayer.name)"
        content.interruptionLevel = .timeSensitive
        
        // Get the saved notification preference for this prayer
        let notificationKey = "\(prayer.name)-notification"
        let optionRawValue = UserDefaults.standard.string(forKey: notificationKey) ?? NotificationOption.standard.rawValue
        let option = NotificationOption(rawValue: optionRawValue) ?? .standard
        
        // Apply notification settings based on preference
        switch option {
        case .silent: return
        case .standard:
            content.sound = .default
        case .adhan:
            content.sound = UNNotificationSound(named: UNNotificationSoundName("azan2.mp3"))
            content.userInfo["customSoundName"] = "azan2.mp3"
        }
        
        // Create calendar components for the trigger
        var components = Calendar.current.dateComponents([.hour, .minute], from: prayer.time)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create unique identifier that includes the date
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
        let identifier = "\(prayer.name)-\(dateString)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Error scheduling notification for \(prayer.name): \(error.localizedDescription)")
            }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Check the userInfo for our custom sound name
        if let customSound = notification.request.content.userInfo["customSoundName"] as? String,
           customSound == "azan2.mp3" {
            // If you have an AVAudioPlayer service for the full-length Adhan, call it here
            AdhanAudioService.shared.playAdhan()
            completionHandler([.banner])
        } else {
            completionHandler([.banner, .sound])
        }
    }
}
