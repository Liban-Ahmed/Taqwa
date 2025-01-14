//
//  QiblaDirectionViewModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//

import SwiftUI
import Combine
import CoreLocation
import CoreMotion
import Adhan

class QiblaDirectionViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var qiblaBearing: Double = 0.0
    @Published var deviceHeading: Double = 0.0
    
    @Published var locationStatus: String = "Determining Location..."
    @Published var locationName: String = "Unknown Location"
    @Published var errorMessage: String?
    
    @Published var accuracy: LocationAccuracy = .low
    @Published var calibrationRequired: Bool = false
    
    /// The difference between device heading and Qibla direction (0–180), for UI display.
    @Published var relativeAngle: Double = 0.0
    
    /// e.g. "to your left", "slight left", "to your right", "straight ahead".
    @Published var directionHint: String = "Straight ahead"
    
    // MARK: - Accuracy Enum
    enum LocationAccuracy {
        case low, medium, high
    }
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    private var internalHeading: Double = 0.0
    private var lastQiblaUpdate: Date?
    private let updateInterval: TimeInterval = 1.0
    
    // For limiting reverse-geocode calls
    private var lastGeocodedLocation: CLLocation?
    private var lastGeocodeTime: Date?
    private let minimumLocationDistance: CLLocationDistance = 100
    private let geocodeInterval: TimeInterval = 30
    
    // Heading offset for device orientation (portrait, landscape, etc.)
    private var headingOffset: Double = 0.0
    
    // MARK: - Initialization
    override init() {
        super.init()
        configureLocationManager()
        startDeviceOrientationUpdates()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Configuration
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10  // Updates every 10 meters
        locationManager.headingFilter = 2    // Updates every 2 degrees
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // MARK: - Public Methods
    
    func startCalibration() {
        locationManager.stopUpdatingHeading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.locationManager.startUpdatingHeading()
        }
    }
    
    func stopAllUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func resumeUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        startDeviceOrientationUpdates()
    }
    
    // MARK: - Device Orientation Handling
    private func startDeviceOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            let orientation = UIDevice.current.orientation
            
            switch orientation {
            case .portrait:
                self.headingOffset = 0
            case .landscapeLeft:
                // Typically offset -90 for iPhone in landscapeLeft
                self.headingOffset = -90
            case .landscapeRight:
                self.headingOffset = 90
            case .portraitUpsideDown:
                self.headingOffset = 180
            default:
                self.headingOffset = 0
            }
        }
    }
    
    // MARK: - Qibla Calculation
    private func updateQiblaBearing(from location: CLLocation) {
        let coords = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        let qiblaDirection = Qibla(coordinates: coords).direction
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            qiblaBearing = qiblaDirection
        }
        
        // After updating qiblaBearing, recalculate relative angle.
        recalcRelativeAngle()
    }
    
    // MARK: - Heading Calculation
    private func updateHeadingContinuously(_ newHeading: Double) {
        // Smooth out abrupt flips near 0/360
        let diff = (newHeading - internalHeading).truncatingRemainder(dividingBy: 360)
        
        if diff > 180 {
            internalHeading -= (360 - diff)
        } else if diff < -180 {
            internalHeading += (360 + diff)
        } else {
            internalHeading += diff
        }
        
        let normalized = internalHeading.truncatingRemainder(dividingBy: 360)
        deviceHeading = normalized < 0 ? normalized + 360 : normalized
        
        // Once deviceHeading is updated, recalc the difference to Qibla
        recalcRelativeAngle()
    }
    
    /// Recalculate the difference between the device heading and qibla bearing
    /// and also produce text instructions like "to your left," "slight right," etc.
    private func recalcRelativeAngle() {
        // The difference in [0, 360)
        var angle = (qiblaBearing - deviceHeading).truncatingRemainder(dividingBy: 360)
        if angle < 0 { angle += 360 }
        
        // If angle <= 180, Qibla is to the RIGHT. Otherwise, to the LEFT.
        if angle <= 180 {
            // Right side
            relativeAngle = angle
            directionHint = angleDirectionText(angle: angle, isLeft: false)
        } else {
            // Left side
            relativeAngle = 360 - angle
            directionHint = angleDirectionText(angle: relativeAngle, isLeft: true)
        }
    }
    
    /// Simple utility to produce "slight left," "to your left," or "straight ahead."
    private func angleDirectionText(angle: Double, isLeft: Bool) -> String {
        // If angle is super small, treat it as "straight ahead"
        if angle < 5 {
            return "Facing The Qibla"
        } else if angle < 20 {
            return isLeft ? "slight left" : "slight right"
        } else {
            return isLeft ? "to your left" : "to your right"
        }
    }
    
    // MARK: - Reverse Geocoding
    private func updateLocationNameIfNeeded(from location: CLLocation) {
        if let lastLocation = lastGeocodedLocation,
           let lastTime = lastGeocodeTime {
            let distance = location.distance(from: lastLocation)
            let timeSinceLastUpdate = Date().timeIntervalSince(lastTime)
            
            if distance < minimumLocationDistance &&
                timeSinceLastUpdate < geocodeInterval {
                return
            }
        }
        
        lastGeocodedLocation = location
        lastGeocodeTime = Date()
        
        let geocoder = CLGeocoder()
        
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let placemarks = try await geocoder.reverseGeocodeLocation(location)
                    if let pm = placemarks.first {
                        await MainActor.run {
                            self.locationName = self.parsePlacemark(pm)
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.locationName = "Location Error: \(error.localizedDescription)"
                    }
                }
            }
            return
        }
        
        // Fallback for iOS < 15
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.locationName = "Location Error: \(error.localizedDescription)"
                    return
                }
                if let placemark = placemarks?.first {
                    self.locationName = self.parsePlacemark(placemark)
                } else {
                    self.locationName = "Unknown Location"
                }
            }
        }
    }
    
    /// Helper to build "809 Bay Dr", "1717 S Grand Ave" etc.
    private func parsePlacemark(_ pm: CLPlacemark) -> String {
        let streetNumber = pm.subThoroughfare ?? ""
        let streetName = pm.thoroughfare ?? ""
        let city = pm.locality ?? ""
        
        // If we have an actual street name and number, show that.
        let addressLine = "\(streetNumber) \(streetName)".trimmingCharacters(in: .whitespaces)
        
        // If missing thoroughfare or subThoroughfare, fallback to city.
        if addressLine.isEmpty {
            return city.isEmpty ? "Unknown Location" : city
        } else {
            return addressLine
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension QiblaDirectionViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            locationStatus = "Location access denied"
            errorMessage = "Please enable location services in Settings."
        case .notDetermined:
            locationStatus = "Requesting location authorization"
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = "Location access granted"
        @unknown default:
            locationStatus = "Unknown location authorization status"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        
        // Update accuracy for the UI
        let accuracyValue = location.horizontalAccuracy
        switch accuracyValue {
        case 0...20:
            self.accuracy = .high
            locationStatus = "High Accuracy"
        case 21...100:
            self.accuracy = .medium
            locationStatus = "Medium Accuracy"
        default:
            self.accuracy = .low
            locationStatus = "Low Accuracy"
        }
        
        // Update Qibla bearing
        updateQiblaBearing(from: location)
        
        // Update location name if needed
        updateLocationNameIfNeeded(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // If heading is invalid, might require calibration
        if newHeading.headingAccuracy < 0 {
            calibrationRequired = true
            return
        }
        calibrationRequired = false
        
        // Adjust for device orientation
        let rawHeading = newHeading.magneticHeading + headingOffset
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            updateHeadingContinuously(rawHeading)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationStatus = "Location access denied"
                errorMessage = "Please enable location services in Settings"
            case .locationUnknown:
                locationStatus = "Unable to determine location"
                errorMessage = "Please check GPS signal"
            default:
                locationStatus = "Location error"
                errorMessage = clError.localizedDescription
            }
        } else {
            locationStatus = "Location error"
            errorMessage = error.localizedDescription
        }
    }
}
