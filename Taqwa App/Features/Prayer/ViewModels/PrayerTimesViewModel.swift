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
    // Add observer for settings changes
    private var settingsObserver: NSObjectProtocol?
    
    init() {
        // Observe settings changes
        settingsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePrayerTimesForSelectedDate()
        }
    }
    
    deinit {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        @MainActor
           func updatePrayerTimesForSelectedDate() {
               fetchPrayerTimes(for: selectedDate)
           }
           
           @MainActor
           func savePrayerState(for prayer: PrayerTime) {
               let baseKey = dayKey(for: selectedDate)
               let key = "\(baseKey)-\(prayer.name)"
               UserDefaults.standard.set(prayer.status.rawValue, forKey: key)
               UserDefaults.standard.synchronize()
           }
    }


    // Use day-only for stable keys
    internal func dayKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year!)-\(components.month!)-\(components.day!)"
    }

    public func prayerTimesForDate(_ date: Date) -> [PrayerTime] {
        guard let location = locationManager.lastKnownLocation else {
            return []
        }
        
        let prayerTimesForDay = prayerCalculationService.getPrayerTimes(
            location: (location.coordinate.latitude, location.coordinate.longitude),
            date: date
        )
        
        var dailyTimes = prayerTimesForDay.times
        
        // Load persisted statuses
        let baseKey = dayKey(for: date)
        for i in dailyTimes.indices {
            let prayerName = dailyTimes[i].name
            let key = "\(baseKey)-\(prayerName)"
            if let savedStatus = UserDefaults.standard.string(forKey: key),
               let status = PrayerStatus(rawValue: savedStatus) {
                dailyTimes[i].status = status
            }
        }
        return dailyTimes
    }
    
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

                    // load prayer states from user defaults
                    self.loadPrayerStates()
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
    
    // Save status using dayKey
    func savePrayerState(for prayer: PrayerTime) {
        let baseKey = dayKey(for: selectedDate)
        let key = "\(baseKey)-\(prayer.name)"
        UserDefaults.standard.set(prayer.status.rawValue, forKey: key)
        UserDefaults.standard.synchronize()
    }

    func loadPrayerStates() {
        let baseKey = dayKey(for: selectedDate)
        for index in prayerTimes.indices {
            let prayerName = prayerTimes[index].name
            let key = "\(baseKey)-\(prayerName)"
            if let savedStatus = UserDefaults.standard.string(forKey: key),
               let status = PrayerStatus(rawValue: savedStatus) {
                prayerTimes[index].status = status
            } else {
            }
        }
    }
    
    private func updateCurrentAndNextPrayer(prayerTimes: [PrayerTime]) {
        let currentTime = Date()
        // If selectedDate is not today, use current day for next prayer
        guard Calendar.current.isDateInToday(selectedDate) else {
            // Keep the logic defaulting to today's times
            return
        }

        let nextPrayerIndex = prayerTimes.firstIndex(where: { $0.time > currentTime })
        var currentPrayer: String = ""
        var timeRemaining: String = ""

        if let nextPrayerIndex = nextPrayerIndex {
            let currentPrayerTime = nextPrayerIndex > 0 ? prayerTimes[nextPrayerIndex - 1].time : Date()
            let nextPrayer = prayerTimes[nextPrayerIndex]
            let nextPrayerTime = nextPrayer.time

            let totalInterval = nextPrayerTime.timeIntervalSince(currentPrayerTime)
            let elapsedInterval = currentTime.timeIntervalSince(currentPrayerTime)
            let progress = max(0, min(1, elapsedInterval / totalInterval))

            currentPrayer = nextPrayerIndex > 0 ? prayerTimes[nextPrayerIndex - 1].name : "Isha"

            let remainingSecondsTotal = Int(nextPrayerTime.timeIntervalSince(currentTime))
            if remainingSecondsTotal <= 0 {
                timeRemaining = "0 secs"
            } else {
                let hrs = remainingSecondsTotal / 3600
                let mins = (remainingSecondsTotal % 3600) / 60
                let secs = remainingSecondsTotal % 60

                if hrs > 0 {
                    timeRemaining = hrs > 1
                    ? "\(hrs) hrs \(mins) mins"
                    : "\(hrs) hr \(mins) mins"
                } else if mins > 0 {
                    timeRemaining = mins > 1
                    ? "\(mins) mins \(secs) secs"
                    : "\(mins) min \(secs) secs"
                } else {
                    timeRemaining = secs > 1
                    ? "\(secs) secs"
                    : "\(secs) sec"
                }
            }
            timeRemaining += " until \(nextPrayer.name)"

            DispatchQueue.main.async {
                self.currentPrayer = currentPrayer
                self.timeRemaining = timeRemaining
                self.progress = progress
            }
        } else {
            // Next day scenario
            let fajrTomorrow = prayerTimes.first!.time.addingTimeInterval(86400)
            let lastPrayerTime = prayerTimes.last!.time
            let totalInterval = fajrTomorrow.timeIntervalSince(lastPrayerTime)
            let elapsedInterval = currentTime.timeIntervalSince(lastPrayerTime)
            let progress = max(0, min(1, elapsedInterval / totalInterval))

            currentPrayer = "Isha"

            let remainingSecondsTotal = Int(fajrTomorrow.timeIntervalSince(currentTime))
            if remainingSecondsTotal <= 0 {
                timeRemaining = "0 secs"
            } else {
                let hrs = remainingSecondsTotal / 3600
                let mins = (remainingSecondsTotal % 3600) / 60
                let secs = remainingSecondsTotal % 60

                if hrs > 0 {
                    timeRemaining = hrs > 1
                    ? "\(hrs) hrs \(mins) mins"
                    : "\(hrs) hr \(mins) mins"
                } else if mins > 0 {
                    timeRemaining = mins > 1
                    ? "\(mins) mins \(secs) secs"
                    : "\(mins) min \(secs) secs"
                } else {
                    timeRemaining = secs > 1
                    ? "\(secs) secs"
                    : "\(secs) sec"
                }
            }
            timeRemaining += " until Fajr"

            DispatchQueue.main.async {
                self.currentPrayer = currentPrayer
                self.timeRemaining = timeRemaining
                self.progress = progress
            }
        }
    }
    
}
