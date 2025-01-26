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
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var onLocationUpdate: ((CLLocation) -> Void)?
    
    // Add completion handlers for error cases
    private var onLocationError: ((Error) -> Void)?
    
    // Properties for optimization
    var lastKnownLocation: CLLocation?
    private let distanceFilter: CLLocationDistance = 100 // meters
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    // Status tracking
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .other
    }
    
    func requestLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            self.locationError = LocationError.accessDenied
        case .authorizedWhenInUse, .authorizedAlways:
            // Add default handlers for the required parameters
            startUpdatingLocation(
                onUpdate: { [weak self] location in
                    self?.lastKnownLocation = location
                },
                onError: { [weak self] error in
                    self?.locationError = error
                }
            )
        @unknown default:
            break
        }
    }
    
    func startUpdatingLocation(onUpdate: @escaping (CLLocation) -> Void,
                               onError: @escaping (Error) -> Void) {
        self.onLocationUpdate = onUpdate
        self.onLocationError = onError
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy <= 100 else { return }
        
        lastKnownLocation = location
        onLocationUpdate?(location)
        
        // Optimize battery by stopping updates if accuracy is good enough
        if location.horizontalAccuracy <= desiredAccuracy {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                locationError = LocationError.accessDenied
            case .locationUnknown:
                locationError = LocationError.locationUnavailable
            default:
                locationError = error
            }
        }
        onLocationError?(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = LocationError.accessDenied
        default:
            break
        }
    }
}

// MARK: - Custom Location Errors
enum LocationError: LocalizedError {
    case accessDenied
    case locationUnavailable
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Location access denied. Please enable location services in Settings."
        case .locationUnavailable:
            return "Unable to determine location. Please check GPS signal."
        }
    }
}
