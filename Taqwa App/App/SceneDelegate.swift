//
//  SceneDelegate.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import UserNotifications

func requestNotificationAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification authorization granted")
        } else if let error = error {
            print("Notification authorization denied: \(error.localizedDescription)")
        }
    }
}
