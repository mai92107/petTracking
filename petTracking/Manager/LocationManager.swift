//
//  LocationManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/31.
//

import Foundation
import CoreLocation


protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ service: LocationManager, location: CLLocation)
    func didChangeAuthorization(_ service: LocationManager, status: CLAuthorizationStatus)
    func didFail(_ service: LocationManager, error: Error)
}

class LocationManager: NSObject {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    
    // 用於記錄用戶是否想要開始追蹤(用於權限請求後自動開始)
    private var shouldStartAfterAuthorization = false
    
    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.5
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: - Authorization Checking
    
    func requestAuthorizationAndStart() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            // 權限被拒絕
            print("❌ 定位權限被拒絕或受限")
            delegate?.didChangeAuthorization(self, status: status)
        case .notDetermined:
            // 權限未決定,請求權限並標記為需要自動開始
            shouldStartAfterAuthorization = true
            locationManager.requestAlwaysAuthorization()
            print("🔐 請求定位權限")
        @unknown default:
            break
        }
    }
    /// 檢查權限狀態(用於 App 回到前景時)
    func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        delegate?.didChangeAuthorization(self, status: status)
    }
    
    
    // MARK: - Tracking Controls
    func startUpdatingLocation() {
        print("📍 開始追蹤位置")
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("📍 停止追蹤位置")
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        delegate?.didUpdateLocation(self, location: last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFail(self, error: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 定位權限變更: \(status.rawValue)")
        delegate?.didChangeAuthorization(self, status: status)
        
        // 如果用戶剛授權且需要自動開始追蹤
        if shouldStartAfterAuthorization {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                shouldStartAfterAuthorization = false
                startUpdatingLocation()
            case .denied, .restricted:
                shouldStartAfterAuthorization = false
            default:
                break
            }
        }
    }
}
