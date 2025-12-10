//
//  LocationManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/31.
//
import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(lng: Double, lat: Double)
    func didChangeAuthorization(status: CLAuthorizationStatus)
    func didFail(error: Error)
}

class LocationManager: NSObject {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    var lastKnownLocation: CLLocation?
    
    static let shared = LocationManager()
    
    var isTracking = false
    var newRecordRef: String?
    
    private var shouldStartAfterAuthorization = false
    
    private let minDistance: CLLocationDistance = 10.0      // 至少移動 10 公尺
    private let maxTimeInterval: TimeInterval = 20.0        // 最多 20 秒
    
    private var lastSentTime: Date?
    private var lastSentLocation: CLLocation?
    private var pendingLocation: CLLocation?
    
    // MARK: - Init
    override private init() {
        super.init()
        setupConfig()
    }
    
    // MARK: - Config
    private func setupConfig() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .otherNavigation
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: - Authorization
    func requestAuthorizationAndStart() { // 改成doOnSuccess() 執行同意後的動作 // 移到權限中心 統一取得必要權限
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted: print("❌ 定位權限被拒絕或受限")
            delegate?.didChangeAuthorization(status: locationManager.authorizationStatus)
        case .notDetermined:
            shouldStartAfterAuthorization = true
            locationManager.requestAlwaysAuthorization()
            print("🔐 請求「永遠」定位權限")
        @unknown default: break
        }
    }
    
    func checkAuthorizationStatus() {
        delegate?.didChangeAuthorization(status: locationManager.authorizationStatus)
    }
    
    // MARK: - Tracking
    func startUpdatingLocation() {
        guard !isTracking else { return }
        isTracking = true
        newRecordRef = UUID().uuidString
        print("開始startUpdatingLocation")

        lastSentTime = nil
        lastSentLocation = nil
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        guard isTracking else { return }
        isTracking = false
        newRecordRef = nil
        
        locationManager.stopUpdatingLocation()
    }
    
    private func sendLocation(_ location: CLLocation) {
        let now = Date()
        
        let distance = lastSentLocation?.distance(from: location) ?? 0.0
        let timeInterval = lastSentTime.map { now.timeIntervalSince($0) } ?? maxTimeInterval
                
        guard distance >= minDistance || timeInterval >= maxTimeInterval else { return }

        // 更新紀錄
        lastKnownLocation = location
        lastSentLocation = location
        lastSentTime = now

        let lng = LocationUtil.shared.Get7NumberLocation(double: location.coordinate.longitude)
        let lat = LocationUtil.shared.Get7NumberLocation(double: location.coordinate.latitude)
        
        print("✅ 發送定位 | 距離: \(String(format: "%.1f", distance))m | 時間間隔: \(String(format: "%.1f", timeInterval))s")
        delegate?.didUpdateLocation(lng: lng, lat: lat)
        
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        
        // 每次更新時先存起來，實際發送由 Timer 或距離判斷決定
        pendingLocation = location
        sendLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFail(error: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        delegate?.didChangeAuthorization(status: status)
        
        if shouldStartAfterAuthorization {
            if status == .authorizedAlways || status == .authorizedWhenInUse{
                shouldStartAfterAuthorization = false
                startUpdatingLocation()
            }
        }
    }
}
