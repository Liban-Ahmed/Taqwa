//
//  NotificationOption.swift.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/10/25.
//
import SwiftUI
import UserNotifications
enum NotificationOption: String, CaseIterable {
    case silent = "Silent"
    case standard = "Standard"  // Changed from "Banner"
    case adhan = "Adhan"
    
    var icon: String {
        switch self {
        case .silent: return "bell.slash.fill"
        case .standard: return "bell.badge.fill"
        case .adhan: return "wave.3.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .silent: return .gray
        case .standard: return .blue
        case .adhan: return .green
        }
    }
    
    var description: String {
        switch self {
        case .silent: return "No notifications"
        case .standard: return "Default sound"
        case .adhan: return "Play Adhan sound"
        }
    }
}
