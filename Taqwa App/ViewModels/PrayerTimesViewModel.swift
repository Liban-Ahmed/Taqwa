//
//  PrayerTimesViewModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import Foundation
import Adhan
import CoreLocation

// MARK: - Prayer Times ViewModel
/// ViewModel to handle prayer times logic and provide data to the views.

class PrayerTimesViewModel: ObservableObject {
    @Published var prayerTimes: [PrayerTime] = []
    @Published var locationName: String = ""
    @Published var selectedDate: Date = Date() // Add selected date property
    @Published var currentPrayer: String = "" // Current prayer name
    @Published var timeRemaining: String = "" // Time remaining until next prayer
    @Published var hijriDate: String = "" // Islamic calendar date
    @Published var progress: Double = 0.0 // Time progress for next prayer

    private let prayerCalculationService = PrayerCalculationService()
    private let locationManager = LocationManager()
    private let geocoder = CLGeocoder()
    private var timer: Timer?

    func fetchPrayerTimes(for date: Date) {
        locationManager.requestLocationAuthorization()
        locationManager.startUpdatingLocation { [weak self] location in
            guard let self = self else { return }

            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            // Fetch prayer times
            let prayerTimesForDay = self.prayerCalculationService.getPrayerTimes(location: (latitude, longitude), date: date)

            // Update current and next prayer
            self.scheduleTimer(for: prayerTimesForDay.times, location: location)

            // Perform reverse geocoding
            self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                let locationName = placemarks?.first?.locality ?? "Unknown Location"

                // Update the published properties
                DispatchQueue.main.async {
                    self.prayerTimes = prayerTimesForDay.times
                    self.locationName = locationName
                    self.hijriDate = IslamicDateConverter.convertToHijri(date: date) // Update Hijri date
                }
            }
        }
    }

    func updatePrayerTimesForSelectedDate() {
        fetchPrayerTimes(for: selectedDate)
    }

    private func scheduleTimer(for prayerTimes: [PrayerTime], location: CLLocation) {
        timer?.invalidate() // Cancel any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCurrentAndNextPrayer(prayerTimes: prayerTimes)
        }
    }

    private func updateCurrentAndNextPrayer(prayerTimes: [PrayerTime]) {
        let currentTime = Date()
        let nextPrayerIndex = prayerTimes.firstIndex(where: { $0.time > currentTime })
        var currentPrayer: String = ""
        var timeRemaining: String = ""

        if let nextPrayerIndex = nextPrayerIndex {
            let currentPrayerTime = nextPrayerIndex > 0 ? prayerTimes[nextPrayerIndex - 1].time : Date()
            let nextPrayer = prayerTimes[nextPrayerIndex]
            let nextPrayerTime = nextPrayer.time

            // Calculate progress
            let totalInterval = nextPrayerTime.timeIntervalSince(currentPrayerTime)
            let elapsedInterval = currentTime.timeIntervalSince(currentPrayerTime)
            let progress = max(0, min(1, elapsedInterval / totalInterval)) // Ensure progress is between 0 and 1

            currentPrayer = nextPrayerIndex > 0 ? prayerTimes[nextPrayerIndex - 1].name : "Isha"
            let remainingTime = nextPrayerTime.timeIntervalSince(currentTime)
            let hours = Int(remainingTime) / 3600
            let minutes = (Int(remainingTime) % 3600) / 60
            timeRemaining = "\(hours) hr \(minutes) mins until \(nextPrayer.name)"

            // Update published properties
            DispatchQueue.main.async {
                self.currentPrayer = currentPrayer
                self.timeRemaining = timeRemaining
                self.progress = progress
            }
        } else {
            // Handle Isha to Fajr transition
            let fajrTomorrow = prayerTimes.first!.time.addingTimeInterval(86400) // Add 24 hours to Fajr
            let lastPrayerTime = prayerTimes.last!.time
            let totalInterval = fajrTomorrow.timeIntervalSince(lastPrayerTime)
            let elapsedInterval = currentTime.timeIntervalSince(lastPrayerTime)
            let progress = max(0, min(1, elapsedInterval / totalInterval)) // Ensure progress is between 0 and 1

            currentPrayer = "Isha"
            let remainingTime = fajrTomorrow.timeIntervalSince(currentTime)
            let hours = Int(remainingTime) / 3600
            let minutes = (Int(remainingTime) % 3600) / 60
            timeRemaining = "\(hours) hr \(minutes) mins until Fajr"

            // Update published properties
            DispatchQueue.main.async {
                self.currentPrayer = currentPrayer
                self.timeRemaining = timeRemaining
                self.progress = progress
            }
        }
    }
}
