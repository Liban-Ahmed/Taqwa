//
//  NotificationService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import UserNotifications

class NotificationService {
    // Singleton instance
    static let shared = NotificationService()
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .denied:
                print("Notifications are disabled")
            case .authorized:
                print("Notifications are enabled")
            default:
                break
            }
        }
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
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
