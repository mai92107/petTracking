//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class TrackingVC: UIViewController {
   
    private enum Constants {
        static let defaultLatLabel = "緯度: ----------"
        static let defaultLngLabel = "經度: -----------"
        static let coordinatePrecision = 7
    }
    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "Pet Tracking System", with: .title)
    private let actionButton = PTButton(title: "開始定位")
    private let latitudeLabel = PTLabel(text: Constants.defaultLatLabel, with: .subtitle)
    private let longitudeLabel = PTLabel(text: Constants.defaultLngLabel, with: .subtitle)
    private let mqttStatusLabel = PTLabel(text: "MQTT: 未連線", with: .subtitle)
    
    // MARK: - Properties
    private let locationManager = LocationManager()
    private var isTracking = false
    
    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMQTT()
        setupAppLifecycleObservers()
        
        setupNetworkMonitoring()

        // 初始化 LocationService
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.checkAuthorizationStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NetworkMonitor.shared.stopMonitoring()
        stopTracking()
    }
    
    // MARK: - Setups
    private func setupUI() {
        view.backgroundColor = .ptQuaternary
        
        actionButton.addTarget(self, action: #selector(toggleTracking), for: .touchUpInside)
        
        let locationStackView = PTVerticalStackView(
            in: 5,
            views: [longitudeLabel, latitudeLabel, mqttStatusLabel]
        )
        
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        view.addSubview(locationStackView)
        
        let padding: CGFloat = 40
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            
            locationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationStackView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -padding),
        ])
    }
    
    private func setupMQTT() {
        MQTTManager.shared.connect()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mqttStatusChanged),
            name: NSNotification.Name("MQTTStatusChanged"),
            object: nil
        )
    }
    
    private func setupNetworkMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: NSNotification.Name("NetworkStatusChanged"),
            object: nil
        )
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc private func networkStatusChanged(){
        
    }
    
    @objc private func toggleTracking() {
        isTracking ? stopTracking() : startTracking()
    }
    
    @objc private func mqttStatusChanged(_ notification: Notification) {
        guard let isConnected = notification.userInfo?["isConnected"] as? Bool else { return }

        DispatchQueue.main.async { [weak self] in
            self?.mqttStatusLabel.text = isConnected ? "MQTT: 已連線 ✓" : "MQTT: 未連線 ᙮"
            self?.mqttStatusLabel.textColor = isConnected ? .ptSecondary : .ptTertiary
        }
    }
    
    @objc private func appWillEnterForeground() {
        print("📱 App 回到前景")
        locationManager.checkAuthorizationStatus()
    }
    
    // MARK: - Tracking Control
    private func startTracking() {
        if !MQTTManager.shared.isConnect{
            AlertManager.showMessage(on: self, title: "系統錯誤", message: "MQTT 未連線，訊息無法送出\n請稍後嘗試")
            return
        }
         
        checkAndSetupAuth()
        locationManager.requestAuthorizationAndStart()
        
        // 更新UI
        isTracking = true
        actionButton.setTitle("停止定位", for: .normal)
    }

    private func stopTracking() {
        locationManager.stopUpdatingLocation()

        // 更新UI
        isTracking = false
        actionButton.setTitle("開始定位", for: .normal)
        resetLocationLabels()
    }
    
    private func resetLocationLabels() {
        latitudeLabel.resetLabel(text: Constants.defaultLatLabel, with: .subtitle)
        longitudeLabel.resetLabel(text: Constants.defaultLngLabel, with: .subtitle)
    }
    
    // MARK: - Auth Management
    private func checkAndSetupAuth() {
        // 先塞預設值
        AuthManager.shared.saveJWT("mo;figaewrhjgf;ie")
        if !AuthManager.shared.isLoggedIn() {
            showLoginAlert()
        }
    }
    
    // MARK: - UI Update & MQTT Send
    private func processLocation(_ location: CLLocation) {
        guard location.horizontalAccuracy >= 0 else {
            print("⚠️ 無效的定位數據")
            return
        }

        let longitude = String(format: "%.7f", location.coordinate.longitude)
        let latitude = String(format: "%.7f", location.coordinate.latitude)
        guard let lat = Double(latitude), let lng = Double(longitude) else { return }

        print("📍 定位更新 - 緯度:\(latitude), 經度:\(longitude), 精度:±\(Int(location.horizontalAccuracy))m")
        
        updateLocationDisplay(latitude: lat, longitude: lng)
        sendLocationData(latitude: lat, longitude: lng)
    }
    
    private func updateLocationDisplay(latitude: Double, longitude: Double) {
        let latDirection = latitude >= 0 ? "北緯" : "南緯"
        let lngDirection = longitude >= 0 ? "東經" : "西經"
        
        latitudeLabel.text = "\(latDirection): \(abs(latitude))°"
        longitudeLabel.text = "\(lngDirection): \(abs(longitude))°"
    }
    
    private func sendLocationData(latitude: Double, longitude: Double) {
        guard let jwt = AuthManager.shared.getJWT() else {
            mqttStatusLabel.text = "MQTT: 未登入"
            mqttStatusLabel.textColor = .systemRed
            stopTracking()
            print("⚠️ 無 JWT Token")
            return
        }
        
        MQTTUtils.shared.publishLocation(
            latitude: latitude,
            longitude: longitude,
            jwt: jwt
        )
    }
    
    // MARK: - Alerts
    private func showLoginAlert() {
        showLoginAlert {
            print("需要導向登入頁面")
        }
    }
}

// MARK: - LocationServiceDelegate
extension TrackingVC: LocationManagerDelegate {
    func didUpdateLocation(_ service: LocationManager, location: CLLocation) {
        processLocation(location)
    }
    
    func didChangeAuthorization(_ service: LocationManager, status: CLAuthorizationStatus) {
        print("📍 定位權限變更: \(status.rawValue)")
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied, .restricted:
            print("❌ 定位權限被拒絕或受限")
            if isTracking{
                stopTracking()
                showPermissionDeniedAlert()
            }
        case .notDetermined:
            print("⚠️ 尚未決定定位權限")
        @unknown default:
            break
        }
    }
    
    func didFail(_ service: LocationManager, error: Error) {
        print("❌ 定位錯誤: \(error.localizedDescription)")
        latitudeLabel.text = "定位失敗"
        latitudeLabel.textColor = .systemRed
        longitudeLabel.text = ""
    }
    
    // MARK: - Helper
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
