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
    
    static let shared = LocationManager()
    
    // 追蹤狀態
    var isTracking = false
    var lastKnownLocation: CLLocation?
    var newRecordRef: String?
    
    // 用於權限請求後自動開始
    private var shouldStartAfterAuthorization = false
    
    private let minDistance: CLLocationDistance = 5.0           // 至少移動 5 公尺
    private let maxTimeInterval: TimeInterval = 30.0            // 最多間隔 30 秒
    private var lastSentTime: Date = .distantPast               // 上次真正發送的時間
    
    // MARK: - Init
    override private init() {
        super.init()
        locationManager.delegate = self
        
        // 調整為更省電但仍精準的設定
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 3.0                       // 先用 3m 讓系統先過濾垃圾點
        locationManager.pausesLocationUpdatesAutomatically = true  // 允許系統在靜止時自動暫停（省電！）
        locationManager.activityType = .otherNavigation            // 適合寵物追蹤的類型
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // MARK: - Authorization
    func requestAuthorizationAndStart() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            print("❌ 定位權限被拒絕或受限")
            delegate?.didChangeAuthorization(status: status)
        case .notDetermined:
            shouldStartAfterAuthorization = true
            locationManager.requestAlwaysAuthorization()
            print("🔐 請求「永遠」定位權限")
        @unknown default:
            break
        }
    }
    
    func checkAuthorizationStatus() {
        delegate?.didChangeAuthorization(status: locationManager.authorizationStatus)
    }
    
    // MARK: - Tracking Controls
    func startUpdatingLocation() {
        guard !isTracking else { return }
        print("📍 開始追蹤位置")
        isTracking = true
        newRecordRef = UUID().uuidString
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        guard isTracking else { return }
        print("📍 停止追蹤位置")
        isTracking = false
        newRecordRef = nil
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy >= 0 else {
            print("⚠️ 無效的定位數據")
            return
        }
        
        let now = Date()
        let timeIntervalSinceLastSend = now.timeIntervalSince(lastSentTime)
        
        // 計算與上次「真正發送」的位置距離
        let distanceFromLastSent = lastKnownLocation?.distance(from: location) ?? Double.greatestFiniteMagnitude
        
        // 雙條件判斷：滿足「距離」或「時間」任一條件就發送
        let shouldSend = distanceFromLastSent >= minDistance || timeIntervalSinceLastSend >= maxTimeInterval
        
        if shouldSend {
            lastKnownLocation = location
            lastSentTime = now
            
            let lng = LocationUtil.shared.Get7NumberLocation(double: location.coordinate.longitude)
            let lat = LocationUtil.shared.Get7NumberLocation(double: location.coordinate.latitude)
            
            print("✅ 發送定位 | 距離: \(String(format: "%.1f", distanceFromLastSent))m | 時間間隔: \(String(format: "%.1f", timeIntervalSinceLastSend))s")
            delegate?.didUpdateLocation(lng: lng, lat: lat)
            lastSentTime = .distantPast
        } else {
            // 可選：靜音記錄被過濾的點（除錯用）
             print("filtered location | 距離: \(String(format: "%.1f", distanceFromLastSent))m | 剩 \(String(format: "%.1f", maxTimeInterval - timeIntervalSinceLastSend))s")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFail(error: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 權限變更: \(status.rawValue)")
        delegate?.didChangeAuthorization(status: status)
        
        if shouldStartAfterAuthorization {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                shouldStartAfterAuthorization = false
                startUpdatingLocation()
            case .denied, .restricted:
                shouldStartAfterAuthorization = false
            default: break
            }
        }
    }
}
