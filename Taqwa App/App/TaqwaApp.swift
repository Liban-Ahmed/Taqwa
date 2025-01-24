//
//  Taqwa_AppApp.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI
import SwiftData

@main
struct Taqwa_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        // Add this line to set notification delegate
        NotificationService.shared.setupDailyNotificationRefresh()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
