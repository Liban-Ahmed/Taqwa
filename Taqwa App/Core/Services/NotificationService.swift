//
//  NotificationService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import Foundation
import UserNotifications
import UIKit
import CoreLocation

class NotificationService {
    static let shared = NotificationService()
    private let prayerCalculationService = PrayerCalculationService()
    private let locationManager = LocationManager()
    private let notificationManager = NotificationPermissionManager.shared
    
    // Store current prayer times and selected date
    private var currentPrayerTimes: [PrayerTime] = []
    private var selectedDate: Date = Date()
    
    func scheduleNotifications(with prayerTimes: [PrayerTime], for date: Date) {
        self.currentPrayerTimes = prayerTimes
        self.selectedDate = date
        
        notificationManager.checkPermissionStatus { status in
            switch status {
            case .notDetermined:
                self.requestPermissions()
            case .denied:
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            case .authorized:
                self.scheduleAuthorizedNotifications(prayerTimes: prayerTimes, date: date)
            default:
                break
            }
        }
    }
    
    func scheduleNotificationsForNextDay() {
        let dates = [Date(), Calendar.current.date(byAdding: .day, value: 1, to: Date())!]
        
        if let location = locationManager.lastKnownLocation {
            for date in dates {
                let prayerTimes = prayerCalculationService.getPrayerTimes(
                    location: (location.coordinate.latitude, location.coordinate.longitude),
                    date: date
                )
                scheduleAuthorizedNotifications(prayerTimes: prayerTimes.times, date: date)
            }
        } else {
            locationManager.startUpdatingLocation { [weak self] location in
                guard let self = self else { return }
                for date in dates {
                    let prayerTimes = self.prayerCalculationService.getPrayerTimes(
                        location: (location.coordinate.latitude, location.coordinate.longitude),
                        date: date
                    )
                    self.scheduleAuthorizedNotifications(prayerTimes: prayerTimes.times, date: date)
                }
            }
        }
    }
    
    private func requestPermissions() {
        notificationManager.requestPermissions { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.scheduleAuthorizedNotifications(
                    prayerTimes: self.currentPrayerTimes,
                    date: self.selectedDate
                )
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    private func scheduleAuthorizedNotifications(prayerTimes: [PrayerTime], date: Date) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for prayer in prayerTimes {
            scheduleNotification(for: prayer, on: date)
        }
    }
    
    private func scheduleNotification(for prayer: PrayerTime, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = prayer.name
        content.body = "It's time for \(prayer.name)"
        content.interruptionLevel = .timeSensitive
        
        switch prayer.notificationOption {
        case .silent: return
        case .standard:
            content.sound = .default
        case .adhan:
            if let soundURL = Bundle.main.url(forResource: "azan2", withExtension: "mp3") {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(soundURL.lastPathComponent))
                content.userInfo["customSoundName"] = "azan2.mp3"
            } else {
                print("⚠️ Prayer call sound file not found")
                content.sound = .default
            }
        }
        
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
    
    private func showPermissionAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive prayer time alerts",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            self.notificationManager.openSettingsIfNeeded()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        rootViewController.present(alert, animated: true)
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
