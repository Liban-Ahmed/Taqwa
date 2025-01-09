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
    
    // MARK: - Published Properties (Observed by SwiftUI Views)
    @Published var qiblaBearing: Double = 0.0
    @Published var deviceHeading: Double = 0.0
    
    @Published var locationStatus: String = "Determining Location..."
    @Published var locationName: String = "Unknown Location"
    @Published var errorMessage: String?
    
    @Published var accuracy: LocationAccuracy = .low
    @Published var calibrationRequired: Bool = false
    
    // MARK: - Accuracy Enum
    enum LocationAccuracy {
        case low, medium, high
    }
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    /// Stores heading in a continuous manner to avoid abrupt flips around 0°/360°.
    private var internalHeading: Double = 0.0
    
    /// If you want to limit Qibla updates (e.g., every X seconds), track the last update time.
    private var lastQiblaUpdate: Date?
    private let updateInterval: TimeInterval = 1.0
    
    // Reverse Geocoding Caching
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
        // Clean up everything when this object is deallocated
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
        
        // Begin updates immediately. Alternatively, you could start these only in onAppear of a view.
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // MARK: - Public Methods
    
    /// Forces a calibration cycle by temporarily stopping heading updates.
    func startCalibration() {
        locationManager.stopUpdatingHeading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.locationManager.startUpdatingHeading()
        }
    }
    
    // If you need to stop all location/heading updates (e.g., onDisappear):
    func stopAllUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        motionManager.stopDeviceMotionUpdates()
    }
    
    // If you need to resume updates (e.g., onAppear):
    func resumeUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        startDeviceOrientationUpdates()
    }
    
    // MARK: - Device Orientation Handling
    /// Updates headingOffset based on device orientation via CoreMotion.
    private func startDeviceOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, motion != nil else { return }
            let orientation = UIDevice.current.orientation
            
            switch orientation {
            case .portrait:
                self.headingOffset = 0
            case .landscapeLeft:
                // On iPhone, "landscapeLeft" means device top is to the left.
                // Typically, heading is offset -90 in that scenario.
                self.headingOffset = -90
            case .landscapeRight:
                self.headingOffset = 90
            case .portraitUpsideDown:
                self.headingOffset = 180
            default:
                // For faceUp, faceDown, unknown, etc., do nothing or set to 0
                self.headingOffset = 0
            }
        }
    }
    
    // MARK: - Qibla Calculation
    /// Uses Adhan’s Qibla calculation to update the qiblaBearing based on the user’s current location.
    private func updateQiblaBearing(from location: CLLocation) {
        // Rate limiting example if needed:
        /*
        if let lastUpdate = lastQiblaUpdate, Date().timeIntervalSince(lastUpdate) < updateInterval {
            return
        }
        lastQiblaUpdate = Date()
        */
        
        let coords = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        let qiblaDirection = Qibla(coordinates: coords).direction
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            qiblaBearing = qiblaDirection
        }
    }
    
    // MARK: - Heading Calculation
    /// Smoothly updates `deviceHeading` without abrupt flips.
    private func updateHeadingContinuously(_ newHeading: Double) {
        // Calculate the smallest difference in [–180, 180]
        let diff = (newHeading - internalHeading).truncatingRemainder(dividingBy: 360)
        
        if diff > 180 {
            internalHeading -= 360 - diff
        } else if diff < -180 {
            internalHeading += 360 + diff
        } else {
            internalHeading += diff
        }
        
        // Now clamp it to [0, 360)
        let normalized = internalHeading.truncatingRemainder(dividingBy: 360)
        deviceHeading = normalized < 0 ? normalized + 360 : normalized
    }
    
    // MARK: - Reverse Geocoding
    private func updateLocationNameIfNeeded(from location: CLLocation) {
        // Check if we should update based on distance/time to reduce geocoding calls
        if let lastLocation = lastGeocodedLocation, let lastTime = lastGeocodeTime {
            let distance = location.distance(from: lastLocation)
            let timeSinceLastUpdate = Date().timeIntervalSince(lastTime)
            if distance < minimumLocationDistance && timeSinceLastUpdate < geocodeInterval {
                return
            }
        }
        
        // Update cache
        lastGeocodedLocation = location
        lastGeocodeTime = Date()
        
        // Reverse geocode
        let geocoder = CLGeocoder()
        
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let placemarks = try await geocoder.reverseGeocodeLocation(location)
                    if let pm = placemarks.first {
                        let city = pm.locality ?? "Unknown City"
                        let country = pm.country ?? "Unknown Country"
                        await MainActor.run {
                            self.locationName = "\(city), \(country)"
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
                    let city = placemark.locality ?? "Unknown City"
                    let country = placemark.country ?? "Unknown Country"
                    self.locationName = "\(city), \(country)"
                } else {
                    self.locationName = "Unknown Location"
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension QiblaDirectionViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle changes in authorization if needed
        switch status {
        case .denied, .restricted:
            locationStatus = "Location access denied"
            errorMessage = "Please enable location services in Settings."
        case .notDetermined:
            locationStatus = "Requesting location authorization"
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = "Location access granted"
            // Could start location updates here if not already started
        @unknown default:
            locationStatus = "Unknown location authorization status"
        }
    }
    
    // Called whenever we get a new location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        
        // Update location accuracy display
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
        
        // Reverse geocode location name if needed
        updateLocationNameIfNeeded(from: location)
    }
    
    // Called whenever heading changes
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // If heading is invalid, might require calibration
        if newHeading.headingAccuracy < 0 {
            calibrationRequired = true
            return
        }
        
        calibrationRequired = false
        
        // Adjust for device orientation offset
        let rawHeading = newHeading.magneticHeading + headingOffset
        
        // Smoothly update heading
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            updateHeadingContinuously(rawHeading)
        }
    }
    
    // Called if location manager fails
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
