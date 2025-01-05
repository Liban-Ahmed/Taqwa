//
//  PrayerTimesModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.


import Foundation
import Adhan // Import the Adhan library for prayer time calculations
import CoreLocation

// MARK: - Prayer Time Model
public struct PrayerTime: Identifiable {
    public let id = UUID()
    public let name: String
    public let time: Date
    
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
