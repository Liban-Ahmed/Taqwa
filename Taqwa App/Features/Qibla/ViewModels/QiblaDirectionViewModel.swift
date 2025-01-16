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

class QiblaDirectionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published Properties
    @Published var qiblaBearing: Double = 0.0
    @Published var deviceHeading: Double = 0.0
    @Published var locationStatus: String = "Determining Location..."
    @Published var locationName: String = "Unknown Location"
    @Published var errorMessage: String?
    @Published var accuracy: LocationAccuracy = .low
    @Published var calibrationRequired: Bool = false
    
    // The arrow’s actual displayed angle (difference from Qibla).
    @Published var arrowAngle: Double = 0.0

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private var headingOffset: Double = 0.0
    private var lastQiblaUpdate: Date?
    private let updateInterval: TimeInterval = 1.0
    
    // Cache properties
    private var lastGeocodedLocation: CLLocation?
    private var lastGeocodeTime: Date?
    private let minimumLocationDistance: CLLocationDistance = 100
    private let geocodeInterval: TimeInterval = 30
    
    // Constants
    private let MAKKAH_LATITUDE = 21.4225
    private let MAKKAH_LONGITUDE = 39.8262
    
    enum LocationAccuracy {
        case low, medium, high
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        startDeviceOrientationUpdates()
    }
    
    // MARK: - Setup Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.headingFilter = 2
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy >= 0 else { return }
        
        updateLocationStatus(accuracy: location.horizontalAccuracy)
        updateQiblaBearing(from: location)
        updateLocationNameIfNeeded(from: location)
    }
    
    private func updateLocationStatus(accuracy: CLLocationAccuracy) {
        switch accuracy {
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
    }
    
    private func updateQiblaBearing(from location: CLLocation) {
        let coords = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        let qiblaDirection = Qibla(coordinates: coords).direction
        
        // Update Qibla bearing (no need to animate here unless you want to)
        self.qiblaBearing = qiblaDirection
    }
    
    // MARK: - Angle Helpers
    /// Returns the minimal angular difference in [-180, 180].
    private func deltaAngle(currentAngle: Double, targetAngle: Double) -> Double {
        var diff = (targetAngle - currentAngle).truncatingRemainder(dividingBy: 360)
        if diff < -180 { diff += 360 }
        else if diff > 180 { diff -= 360 }
        return diff
    }
    
    // MARK: - Heading Updates
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else {
            calibrationRequired = true
            return
        }
        calibrationRequired = false
        
        // 1) Determine the best heading value
        let headingValue = newHeading.trueHeading > 0
            ? newHeading.trueHeading
            : newHeading.magneticHeading
        
        // 2) Adjust for portrait/landscape offset
        let adjustedHeading = headingValue + headingOffset
        
        // 3) Update our published deviceHeading (so the View can access it if needed)
        deviceHeading = adjustedHeading.truncatingRemainder(dividingBy: 360)
        
        // 4) Figure out how far from Qibla we are
        let desiredArrowAngle = (qiblaBearing - deviceHeading).truncatingRemainder(dividingBy: 360)
        
        // 5) Smoothly rotate arrowAngle to the desired angle
        let angleChange = deltaAngle(currentAngle: arrowAngle, targetAngle: desiredArrowAngle)
        withAnimation(.easeOut(duration: 0.3)) {
            arrowAngle += angleChange
        }
    }
    
    // MARK: - Error Handling
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
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Device Orientation Updates
    private func startDeviceOrientationUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion else { return }
                
                // Update heading offset based on device orientation
                if UIDevice.current.orientation.isPortrait {
                    self?.headingOffset = 0
                } else if UIDevice.current.orientation.isLandscape {
                    self?.headingOffset = UIDevice.current.orientation == .landscapeLeft ? -90 : 90
                }
            }
        }
    }
    
    // MARK: - Location Name Updates
    private func updateLocationNameIfNeeded(from location: CLLocation) {
        if let lastLocation = lastGeocodedLocation,
           let lastTime = lastGeocodeTime {
            let distance = location.distance(from: lastLocation)
            let timeSinceLastUpdate = -lastTime.timeIntervalSinceNow
            
            guard distance > minimumLocationDistance || timeSinceLastUpdate > geocodeInterval else {
                return
            }
        }
        
        lastGeocodedLocation = location
        lastGeocodeTime = Date()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.locationName = "Location Error: \(error.localizedDescription)"
                    return
                }
                
                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? "Unknown City"
                    let country = placemark.country ?? "Unknown Country"
                    self?.locationName = "\(city), \(country)"
                } else {
                    self?.locationName = "Unknown Location"
                }
            }
        }
    }
    
    // MARK: - Calibration
    func startCalibration() {
        locationManager.stopUpdatingHeading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.locationManager.startUpdatingHeading()
        }
    }
    
    // MARK: - Cleanup
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        motionManager.stopDeviceMotionUpdates()
    }
}
