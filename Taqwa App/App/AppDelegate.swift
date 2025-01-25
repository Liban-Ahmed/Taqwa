//
//  AppDelegate.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import UIKit
import CoreLocation
import UserNotifications
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let locationManager = LocationManager()
    let notificationDelegate = NotificationDelegate.shared
    let notificationPermissionManager = NotificationPermissionManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        // Setup notification permissions with proper error handling
        setupNotifications()
        
        return true
    }
    
    private func setupNotifications() {
        notificationPermissionManager.requestPermissions { granted in
            if granted {
                // Schedule initial notifications after permissions granted
                NotificationService.shared.scheduleNotificationsForNextDay()
            } else {
                // Show alert on main thread
                DispatchQueue.main.async {
                    self.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive prayer time alerts",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            self.notificationPermissionManager.openSettingsIfNeeded()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Get the root view controller to present the alert
        if let rootVC = self.window?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}
        
