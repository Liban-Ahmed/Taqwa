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
    
    func runDebugTests() {
        print("\n=== Prayer Times Debug Test ===")
        
        locationManager.requestLocationAuthorization()
        locationManager.startUpdatingLocation { location in
            let service = PrayerCalculationService()
            let specificDate = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!
            
            let prayerTimes = service.getPrayerTimes(location: (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), date: specificDate)
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = TimeZone.current // Use device timezone
            
            print("\nPrayer times for current location on \(specificDate):")
            print("-------------------------")
            
            for prayer in prayerTimes.times {
                print("\(prayer.name): \(dateFormatter.string(from: prayer.time))")
            }
            print("\n=== End of Debug Test ===\n")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Request notification authorization
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification authorization granted")
                } else if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
            }
            
            #if DEBUG
            runDebugTests()
            #endif
            
            return true 
        }
}
