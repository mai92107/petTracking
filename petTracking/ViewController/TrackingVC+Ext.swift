//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class TrackingVC: UIViewController {
    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "Pet Tracking System", with: .title)
    private let actionButton = PTButton(title: "開始定位", Vpadding: 15, Hpadding: 40)
    private let infoView = TrackingInfoView()
    private let locationManager = LocationManager()
    
    // MARK: - Properties
    private var isTracking = false
    
    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.checkAuthorizationStatus()
    }
    
    // MARK: - Config
    private func setupConfig(){
        actionButton.ptDelegate = self
        locationManager.delegate = self
        MQTTManager.shared.delegate = self
    }
    
    // MARK: - Layout
    private func setupUI() {
        view.backgroundColor = .ptQuaternary
        
        view.addSubview(titleLabel)
        view.addSubview(infoView)
        view.addSubview(actionButton)
        
        let padding: CGFloat = 40
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),

            infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -padding),
            infoView.heightAnchor.constraint(equalToConstant: 100)

        ])
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
        
        if !AuthManager.shared.isLoggedIn(){
            showNotLoginAlert()
            return
        }
        
        locationManager.requestAuthorizationAndStart()
        
        isTracking = true
        actionButton.setTitle("停止定位", for: .normal)
    }
    
    private func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
        actionButton.setTitle("開始定位", for: .normal)
        infoView.locationLabel.resetLabels()
    }
}

// MARK: - LocationManagerDelegate
extension TrackingVC: LocationManagerDelegate {
    func didUpdateLocation(lng: Double, lat: Double) {
        print("📍 定位更新 - 緯度:\(lat), 經度:\(lng)")
        updateLocationDisplay(latitude: lat, longitude: lng)
        sendLocationData(latitude: lat, longitude: lng)
    }
    
    private func updateLocationDisplay(latitude: Double, longitude: Double) {
        infoView.locationLabel.updateLatitude(abs(latitude))
        infoView.locationLabel.updateLongitude(abs(longitude))
    }
    
    private func sendLocationData(latitude: Double, longitude: Double) {
        let jwt = AuthManager.shared.getJWT()!
        MQTTUtils.shared.publishLocation(latitude: latitude, longitude: longitude, jwt: jwt)
    }
    func didChangeAuthorization(status: CLAuthorizationStatus) {       
        switch status {
        case .denied, .restricted:
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
        infoView.locationLabel.showLocationError("定位失敗")
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

extension TrackingVC: MQTTManagerDelegate{
    func mqttMsgGet(topic: String, message: String) {
        print(topic)
    }
    
    func mqttStatusChanged(isConnected: Bool) {
        infoView.mqttStatusLabel.updateMQTTStatus(isConnected: isConnected)
    }
}


#Preview {
    TrackingVC()
}
