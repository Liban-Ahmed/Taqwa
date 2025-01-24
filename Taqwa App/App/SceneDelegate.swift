//
//  SceneDelegate.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import SwiftUI

extension NotificationService {
    func setupDailyNotificationRefresh() {
        // Schedule initial notifications
        scheduleNotificationsForNextDay()
        
        // Setup background refresh
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scheduleNotificationsForNextDay()
        }
        
        // Schedule end-of-day refresh
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        
        let request = UNNotificationRequest(
            identifier: "DailyNotificationRefresh",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
