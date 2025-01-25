//
//  AppDelegate.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import UIKit
import CoreLocation
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let locationManager = LocationManager()
    let notificationDelegate = NotificationDelegate.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        // Request all necessary notification permissions
        requestNotificationPermissions()
        
        return true
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert, .timeSensitive]
        ) { granted, error in
            if granted {
                print("✓ All notification permissions granted")
                // Schedule initial notifications after permissions granted
                NotificationService.shared.scheduleNotificationsForNextDay()
            } else {
                print("⚠️ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
        
