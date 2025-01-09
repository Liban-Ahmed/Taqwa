//
//  LocationManager.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Public Published Properties (Combine-friendly)
    /// Observed by SwiftUI to reflect current location instantly
    @Published public private(set) var lastKnownLocation: CLLocation?
    
    /// Observed by SwiftUI to reflect current heading instantly
    @Published public private(set) var currentHeading: CLHeading?
    
    /// Any errors or status messages you want to surface (optional)
    @Published public private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    
    /// Whether we only want a single location fix or continuous updates
    private var singleFix: Bool = true
    
    /// Closure for callback-style usage (if desired)
    private var onLocationUpdate: ((CLLocation) -> Void)?
    
    // MARK: - Initialization
    override init() {
        super.init()
        configureLocationManager()
    }
    
    // MARK: - Configuration
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // You can also adjust distanceFilter, desiredAccuracy for battery savings
    }
    
    // MARK: - Public Methods
    
    /// Requests user authorization. Ensure your Info.plist has `NSLocationWhenInUseUsageDescription`.
    public func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /**
     Starts location updates.
     
     - parameter singleFix: If `true`, the manager will stop updating after receiving the first valid location.
                            If `false`, it will continue providing location updates.
     - parameter onUpdate:  An optional closure if you want callback-based usage instead of Combine.
    */
    public func startUpdatingLocation(singleFix: Bool = true,
                                      onUpdate: ((CLLocation) -> Void)? = nil) {
        self.singleFix = singleFix
        self.onLocationUpdate = onUpdate
        
        // Start location updates
        locationManager.startUpdatingLocation()
    }
    
    /// Stops all location updates. Good for saving battery when not needed.
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /**
     Starts heading (compass) updates if needed.
     Make sure heading is available on the device or handle gracefully if not.
    */
    public func startUpdatingHeading() {
        guard CLLocationManager.headingAvailable() else {
            print("Heading not available on this device.")
            return
        }
        locationManager.startUpdatingHeading()
    }
    
    /// Stops heading updates.
    public func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    /// Called whenever the location manager gets a valid location update.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Update Published property (SwiftUI gets notified)
        lastKnownLocation = newLocation
        
        // Callback usage if provided
        onLocationUpdate?(newLocation)
        
        // If single-fix mode, stop after first valid location
        if singleFix {
            manager.stopUpdatingLocation()
        }
    }
    
    /// Called whenever the location manager fails to get a location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Convert to CLError for more specific handling
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                manager.stopUpdatingLocation()
                errorMessage = "Location access denied by user."
            case .locationUnknown:
                errorMessage = "Location not available right now."
            default:
                errorMessage = "Location error: \(clError.localizedDescription)"
            }
        } else {
            errorMessage = "Location error: \(error.localizedDescription)"
        }
        
        print("Location Manager Error: \(errorMessage ?? error.localizedDescription)")
    }
    
    /// Called whenever the device heading (compass) updates.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // If heading accuracy is invalid, you could handle calibration
        if newHeading.headingAccuracy < 0 {
            errorMessage = "Compass calibration needed or heading not available."
        } else {
            currentHeading = newHeading
        }
    }
}
