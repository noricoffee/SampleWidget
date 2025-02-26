//
//  LocationManagerHelper.swift
//  SampleWidget
//
//  Created by Noriyuki Yoshida on 2025/01/30.
//

import CoreLocation

final class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}
