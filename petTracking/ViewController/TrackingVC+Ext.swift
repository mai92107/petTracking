//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation
import ActivityKit

final class TrackingVC: BaseVC {
    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "Pet Tracking System", with: .title)
    private let actionButton = PTButton(title: "開始定位", Vpadding: 15, Hpadding: 40)
    private let locationLabel = LocationView()
    
    private var timer: Timer?
    private var seconds = 0

    // MARK: - Properties
    private var isTracking: Bool {
        get { LocationManager.shared.isTracking }
        set { LocationManager.shared.isTracking = newValue }
    }
    
    private var isConnected = MQTTManager.shared.isConnect
    
    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.checkAuthorizationStatus()
        updateUIState()
    }
    
    // MARK: - Config
    private func setupConfig(){
        actionButton.ptDelegate = self
        LocationManager.shared.delegate = self
    }
    
    // MARK: - Layout
    private func setupUI() {
        view.backgroundColor = .ptQuaternary
        
        view.addSubview(titleLabel)
        view.addSubview(locationLabel)
        view.addSubview(actionButton)
        
        let padding: CGFloat = 40
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),

            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -padding),
            locationLabel.heightAnchor.constraint(equalToConstant: 100)

        ])
    }
    
    // 離開返回後畫面
    private func updateUIState() {
        if isTracking {
            actionButton.setTitle("停止定位", for: .normal)
            if let last = LocationManager.shared.lastKnownLocation {
                locationLabel.updateLatitude(abs(last.coordinate.latitude))
                locationLabel.updateLongitude(abs(last.coordinate.longitude))
            }
        } else {
            actionButton.setTitle("開始定位", for: .normal)
            locationLabel.resetLabels()
        }
    }
}

// MARK: - Tracking Control
extension TrackingVC: PtButtonDelegate{
    func onClick(_ sender: PTButton) {
        isTracking ? stopTracking() : startTracking()
    }
    
    private func startTracking() {
        if !MQTTManager.shared.isConnect {
            showFailedMessageAlert(message: "MQTT 未連線，訊息無法送出\n請稍後嘗試")
            return
        }

        if DeviceConfig.deviceId == "" {
            showFailedMessageAlert(message: "非核可裝置，不可紀錄位置")
            return
        }

        LocationManager.shared.requestAuthorizationAndStart()

        // ⭐ 啟動 Dynamic Island
        TrackingManager.shared.start(deviceName: "Pet Tracker")

        // ⭐ 啟動秒數 Timer
        seconds = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.seconds += 1
            TrackingManager.shared.update(seconds: self.seconds)
        }

        isTracking = true
        actionButton.setTitle("停止定位", for: .normal)
    }
    
    private func stopTracking() {
        LocationManager.shared.stopUpdatingLocation()
        isTracking = false
        actionButton.setTitle("開始定位", for: .normal)
        locationLabel.resetLabels()

        // ⭐ 停止 Timer + Live Activity
        timer?.invalidate()
        TrackingManager.shared.stop()
    }
}

// MARK: - LocationManagerDelegate
extension TrackingVC: LocationManagerDelegate {
    func didUpdateLocation(lng: Double, lat: Double) {
        print("📍 定位更新 - 緯度:\(lat), 經度:\(lng)")
        sendLocationData(latitude: lat, longitude: lng)
        updateLocationDisplay(latitude: lat, longitude: lng)
    }
    
    private func updateLocationDisplay(latitude: Double, longitude: Double) {
        locationLabel.updateLatitude(abs(latitude))
        locationLabel.updateLongitude(abs(longitude))
    }
    
    private func sendLocationData(latitude: Double, longitude: Double) {
        guard let jwt = AuthManager.shared.getJWT() else { return }
        guard let dataRef = LocationManager.shared.newRecordRef else { return }
        MQTTUtils.shared.publishLocation(latitude: latitude, longitude: longitude, jwt: jwt, on: dataRef)
    }
    
    func didChangeAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            if isTracking {
                stopTracking()
                showPermissionDeniedAlert()
            }
        default:
            break
        }
    }
    
    func didFail(error: Error) {
        print("❌ 定位錯誤: \(error.localizedDescription)")
        locationLabel.showLocationError("定位失敗")
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "定位權限被拒絕",
            message: "請到設定中開啟定位權限",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "前往設定", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

extension TrackingVC{



}
