//
//  NotificationOption.swift.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/10/25.
//
enum NotificationOption: String, CaseIterable {
    case silent = "Silent"
    case notification = "Notification"
    case adhan = "Adhan"
    
    var icon: String {
        switch self {
        case .silent: return "bell.slash.fill"
        case .notification: return "bell.fill"
        case .adhan: return "speaker.wave.2.fill"
        }
    }
}
