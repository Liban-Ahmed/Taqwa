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
       private let locationManager = LocationManager()
    
    func scheduleNotifications(with prayerTimes: [PrayerTime], for date: Date) {
        // First check if we have notification permissions
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("⚠️ Notifications not authorized")
                return
            }
            
            // Clear existing notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Schedule notifications for each prayer time
            for prayer in prayerTimes {
                self.scheduleNotification(for: prayer, on: date)
            }
        }
    }
    
    
    private func scheduleNotification(for prayer: PrayerTime, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = prayer.name
        content.body = "It's time for \(prayer.name)"
        content.interruptionLevel = .timeSensitive
        
        // Use the prayer's notification option directly
        switch prayer.notificationOption {
        case .silent: return
        case .standard:
            content.sound = .default
        case .adhan:
            if let soundURL = Bundle.main.url(forResource: "azan2", withExtension: "mp3") {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(soundURL.lastPathComponent))
                content.userInfo["customSoundName"] = "azan2.mp3"
            } else {
                print("⚠️ Adhan sound file not found")
                content.sound = .default
            }
        }
        
        // Create daily repeating trigger
        var components = Calendar.current.dateComponents([.hour, .minute], from: prayer.time)
        components.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let identifier = "\(prayer.name)-\(Calendar.current.startOfDay(for: date))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to schedule \(prayer.name) notification: \(error.localizedDescription)")
            } else {
                print("✓ Scheduled \(prayer.name) notification successfully")
            }
        }
    }
    func scheduleNotificationsForNextDay() {
            // First check if we have notification permissions
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                guard let self = self else { return }
                
                guard settings.authorizationStatus == .authorized else {
                    print("⚠️ Notifications not authorized")
                    return
                }
                
                // Get today and tomorrow's dates
                let dates = [Date(), Calendar.current.date(byAdding: .day, value: 1, to: Date())!]
                
                // Get prayer times for both days if location is available
                if let location = self.locationManager.lastKnownLocation {
                    for date in dates {
                        let prayerTimes = self.prayerCalculationService.getPrayerTimes(
                            location: (location.coordinate.latitude, location.coordinate.longitude),
                            date: date
                        )
                        self.scheduleNotifications(with: prayerTimes.times, for: date)
                    }
                } else {
                    // Request location update
                    self.locationManager.startUpdatingLocation { [weak self] location in
                        guard let self = self else { return }
                        
                        for date in dates {
                            let prayerTimes = self.prayerCalculationService.getPrayerTimes(
                                location: (location.coordinate.latitude, location.coordinate.longitude),
                                date: date
                            )
                            self.scheduleNotifications(with: prayerTimes.times, for: date)
                        }
                    }
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
extension NotificationService {
    func testNotification(for option: NotificationOption) {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Testing \(option.rawValue) notification"
        content.interruptionLevel = .timeSensitive
        
        switch option {
        case .silent:
            content.sound = nil
        case .standard:
            content.sound = .default
        case .adhan:
            if let soundURL = Bundle.main.url(forResource: "azan2", withExtension: "mp3") {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(soundURL.lastPathComponent))
                content.userInfo["customSoundName"] = "azan2.mp3"
            } else {
                print("⚠️ Adhan sound file not found")
                content.sound = .default
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Test notification failed: \(error.localizedDescription)")
            } else {
                print("✓ Test notification scheduled successfully")
            }
        }
    }
}
