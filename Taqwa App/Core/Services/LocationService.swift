//
//  LocationService.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import Foundation
import Adhan // Import the Adhan library for prayer time calculations
import CoreLocation
// MARK: - Location Manager Service
/// Service to handle location updates
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var onLocationUpdate: ((CLLocation) -> Void)?

    // Add a property to store the last known location
    var lastKnownLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation(onUpdate: @escaping (CLLocation) -> Void) {
        self.onLocationUpdate = onUpdate
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Store the last known location
        lastKnownLocation = location
        onLocationUpdate?(location)
        locationManager.stopUpdatingLocation()
    }
    
}
