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

    override init() {
        super.init()
        setupLocationManager()
        startDeviceOrientationUpdates()
    }
    
    // MARK: - Setup Location Manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationStatus = "Location Determined"
        
        let coords = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let qiblaDirection = Qibla(coordinates: coords).direction
        self.qiblaBearing = qiblaDirection
        
        fetchLocationName(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationStatus = "Failed to determine location"
        errorMessage = error.localizedDescription
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else { return }
        deviceHeading = newHeading.magneticHeading
    }
    
    // MARK: - Fetch Location Name
    private func fetchLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let placemark = placemarks?.first, let city = placemark.locality else { return }
            DispatchQueue.main.async {
                self?.locationName = city
            }
        }
    }
    
    // MARK: - Device Orientation Updates
    private func startDeviceOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.02
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
    }
}
