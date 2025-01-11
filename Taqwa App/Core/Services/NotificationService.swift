//
//  NotificationService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import UserNotifications

class NotificationService {
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
