//
//  NotificationPermissionManager.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/24/25.
//
import UserNotifications
import SwiftUI

class NotificationPermissionManager {
    static let shared = NotificationPermissionManager()
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        // Request permission for alerts, sounds, and badges
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("⚠️ Notification permission error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if granted {
                print("✓ Notification permissions granted")
                // Register for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ Notification permissions denied")
            }
            completion(granted)
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    func openSettingsIfNeeded() {
        checkPermissionStatus { status in
            if status == .denied {
                DispatchQueue.main.async {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            }
        }
    }
}
