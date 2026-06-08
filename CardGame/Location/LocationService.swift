//
//  LocationService.swift
//  CardGame
//
//  Requests the device location once, then decides which side of the world the
//  player is on by comparing their longitude to the reference meridian.
//  East of the line -> East side, otherwise -> West side.
//

import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {

    /// The reference meridian given by the assignment.
    static let referenceLongitude: CLLocationDegrees = 34.817549168324334

    private let manager = CLLocationManager()

    /// Called once when a side has been resolved.
    var onSideResolved: ((Side) -> Void)?
    /// Called if the location could not be obtained (denied / error).
    var onFailure: (() -> Void)?

    private var hasResolved = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Pure helper – easy to unit test.
    static func side(forLongitude longitude: CLLocationDegrees) -> Side {
        longitude > referenceLongitude ? .east : .west
    }

    /// Kicks off a single location request, prompting for permission if needed.
    func start() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            onFailure?()
        @unknown default:
            onFailure?()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            onFailure?()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !hasResolved, let location = locations.last else { return }
        hasResolved = true
        // One-shot request already stops updates, but be explicit per the spec:
        manager.stopUpdatingLocation()
        onSideResolved?(Self.side(forLongitude: location.coordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !hasResolved else { return }
        onFailure?()
    }
}
