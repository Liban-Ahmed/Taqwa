//
//  PrayerTimesModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.


import Foundation
import Adhan // Import the Adhan library for prayer time calculations
import CoreLocation
import SwiftUI
import UserNotifications
// MARK: - Prayer Time Model
public struct PrayerTime: Identifiable {
    public let id = UUID()
    public let name: String
    public let time: Date
    var status: PrayerStatus = .none
    var notificationOption: NotificationOption = .standard
    
    public init(name: String, time: Date) {
        self.name = name
        self.time = time
    }
}

// MARK: - Prayer Times Data Model
public struct PrayerTimesForDay {
    public let date: Date
    public let times: [PrayerTime]
    
    public init(date: Date, times: [PrayerTime]) {
        self.date = date
        self.times = times
    }
}

// MARK: - Prayer Status Enum
enum PrayerStatus: String {
    case none, prayed, missed
    
    var iconName: String {
        switch self {
        case .none: return "circle"
        case .prayed: return "checkmark.circle.fill"
        case .missed: return "xmark.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .none: return .gray
        case .prayed: return .green
        case .missed: return .red
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .none: return .clear
        case .prayed: return .green.opacity(0.2)
        case .missed: return .red.opacity(0.2)
        }
    }
    
    func nextStatus() -> PrayerStatus {
        switch self {
        case .none: return .prayed
        case .prayed: return .missed
        case .missed: return .none
        }
    }
}
