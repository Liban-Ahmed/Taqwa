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
    @Published var qiblaBearing: Double = 0.0
    @Published var deviceHeading: Double = 0.0
    @Published var locationStatus: String = "Determining Location..."
    @Published var locationName: String = "Unknown Location"
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private var headingOffset: Double = 0.0
    
    // Cache and throttling properties
    private var lastGeocodedLocation: CLLocation?
    private var lastGeocodeTime: Date?
    private let minimumLocationDistance: CLLocationDistance = 500
    private let geocodeInterval: TimeInterval = 60

    override init() {
        super.init()
        setupLocationManager()
        startDeviceOrientationUpdates()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationStatus = "Location Determined"
        
        let coords = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let qiblaDirection = Qibla(coordinates: coords).direction
        self.qiblaBearing = qiblaDirection
        
        updateLocationNameIfNeeded(from: location)
    }
    
    private func updateLocationNameIfNeeded(from location: CLLocation) {
        // Check time threshold
        if let lastTime = lastGeocodeTime,
           Date().timeIntervalSince(lastTime) < geocodeInterval {
            return
        }
        
        // Check distance threshold
        if let lastLocation = lastGeocodedLocation,
           location.distance(from: lastLocation) < minimumLocationDistance {
            return
        }
        
        fetchLocationName(from: location)
        lastGeocodedLocation = location
        lastGeocodeTime = Date()
    }
    
    private func fetchLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Location name unavailable"
                    return
                }
                
                if let placemark = placemarks?.first {
                    let name = [placemark.locality, placemark.administrativeArea]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                    self.locationName = name.isEmpty ? "Unknown Location" : name
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationStatus = "Failed to determine location"
        errorMessage = error.localizedDescription
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else { return }
        deviceHeading = newHeading.magneticHeading
    }
    
    private func startDeviceOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.02
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
    }
}
