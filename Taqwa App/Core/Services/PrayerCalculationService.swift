//
//  PrayerCalculationService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import Foundation
import Adhan // Import the Adhan library for prayer time calculations
import CoreLocation

// MARK: - Prayer Calculation Service
public class PrayerCalculationService {
    public init() {}
    private func getCalculationParameters() -> CalculationParameters {
        // Get the stored calculation method
        let methodName = UserDefaults.standard.string(forKey: "calculationMethod") ?? "North America"
        
        // Convert string to Adhan calculation method
        var params: CalculationParameters
        switch methodName {
        case "Muslim World League":
            params = CalculationMethod.muslimWorldLeague.params
        case "Egyptian":
            params = CalculationMethod.egyptian.params
        case "Umm Al-Qura":
            params = CalculationMethod.ummAlQura.params
        case "Dubai":
            params = CalculationMethod.dubai.params
        case "Kuwait":
            params = CalculationMethod.kuwait.params
        default:
            params = CalculationMethod.northAmerica.params
        }
        
        // Set madhab
        let madhabName = UserDefaults.standard.string(forKey: "madhab") ?? "Hanafi"
        params.madhab = madhabName == "Shafi" ? .shafi : .hanafi
        
        return params
    }
    public func getPrayerTimes(location: (latitude: Double, longitude: Double), date: Date) -> PrayerTimesForDay {
        let coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        let params = getCalculationParameters()
        
        let currentDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        guard let prayerTimes = PrayerTimes(coordinates: coordinates, date: currentDateComponents, calculationParameters: params) else {
            fatalError("Failed to calculate prayer times")
        }
        
        let times = [
            PrayerTime(name: "Fajr", time: prayerTimes.fajr),
            PrayerTime(name: "Dhuhr", time: prayerTimes.dhuhr),
            PrayerTime(name: "Asr", time: prayerTimes.asr),
            PrayerTime(name: "Maghrib", time: prayerTimes.maghrib),
            PrayerTime(name: "Isha", time: prayerTimes.isha)
        ]
        
        return PrayerTimesForDay(date: date, times: times)
    }
}

// MARK: - Islamic Calendar Conversion Service
public class IslamicDateConverter {
    public static func convertToHijri(date: Date) -> String {
        let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        let formatter = DateFormatter()
        formatter.calendar = hijriCalendar
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US") // Adjust for preferred language
        return formatter.string(from: date)
    }
}
