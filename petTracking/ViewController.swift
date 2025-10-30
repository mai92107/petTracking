//
//  ViewController.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

class TrackingVC: UIViewController {
    
    static let defaultLatLabel:String = "緯度: ----------"
    static let defaultLngLabel:String = "經度: -----------"
    
    let titleLabel = PTLabel(text: "Pet Tracking System", with: .title)
    let actionButton = PTButton(title: "開始定位")
    let latitudeLabel = PTLabel(text: defaultLatLabel, with: .subtitle)
    let longitudeLabel = PTLabel(text: defaultLngLabel, with: .subtitle)
    let mqttStatusLabel = PTLabel(text: "MQTT: 未連線", with: .subtitle)
    
    let recorderInterval: TimeInterval = 1
    
    let locationManager = CLLocationManager()
    var updateTimer: Timer?
    var isTracking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定 CLLocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        view.backgroundColor = .ptQuaternary
        
        actionButton.addTarget(self, action: #selector(toggleTracking), for: .touchUpInside)

        let locationStackView: PTVerticalStackView = PTVerticalStackView(in: 5 ,views: [longitudeLabel, latitudeLabel,mqttStatusLabel])
        
        // 🔥 連接 MQTT
        MQTTManager.shared.connect()
        
        // 🔥 監聽 MQTT 連線狀態
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mqttStatusChanged),
            name: NSNotification.Name("MQTTStatusChanged"),
            object: nil
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
    
    @objc func mqttStatusChanged(_ notification: Notification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool {
            mqttStatusLabel.text = isConnected ? "MQTT: 已連線 ✓" : "MQTT: 未連線"
            mqttStatusLabel.textColor = isConnected ? .ptSecondary : .ptTertiary
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func toggleTracking(){
        if isTracking{
            stopTracking()
        }else{
            startTracking()
        }
    }
    
    func startTracking() {
        isTracking = true
        actionButton.setTitle("停止定位", for: .normal)
        
        // 請求前景定位權限
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // 每0.5秒更新
        updateTimer = Timer.scheduledTimer(withTimeInterval: recorderInterval, repeats: true){
            [weak self] _ in self?.locationManager.requestLocation()
        }
    }
    
    func stopTracking(){
        isTracking = false
        actionButton.setTitle("開始定位", for: .normal)
        
        latitudeLabel.text = TrackingVC.defaultLatLabel
        longitudeLabel.text = TrackingVC.defaultLngLabel
        
        updateTimer?.invalidate()
        updateTimer = nil
        locationManager.stopUpdatingLocation()
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失敗: \(error.localizedDescription)")
        mqttStatusLabel.text = "定位失敗"
        mqttStatusLabel.textColor = .systemRed
    }
}

// MARK: - CLLocationManagerDelegate
extension TrackingVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        checkLoginStatus()
        
        guard let location = locations.last else { return }
    
        // 驗證座標有效性
        guard location.horizontalAccuracy >= 0 else {
            print("無效的定位數據")
            return
        }
            
        // 🔥 取得原始經緯度 (含正負號)
        let longitude = String(format: "%.7f", location.coordinate.longitude)
        let latitude = String(format: "%.7f", location.coordinate.latitude)
        
        // 更新顯示
        updateLocation(lng: longitude, lat: latitude)
        // 發送數據
        sendData(longitude: longitude, latitude: latitude)
        // 取得定位後停止更新,節省電量
        locationManager.stopUpdatingLocation()
    }
    func checkLoginStatus(){
        // 🔥 測試用 JWT (實際應該從登入畫面取得)
        if !AuthManager.shared.isLoggedIn() {
            AuthManager.shared.saveJWT("test_jwt_token_12345")
            print("🧪 已設定測試 JWT")
        }
    }
    
    func updateLocation(lng: String, lat: String) {
        // 處理顯示用的經度
        let longitude = Double(lng)!
        let longitudeAbs = abs(longitude)
        let longitudeDirection = longitude >= 0 ? "東經" : "西經"
        
        // 處理顯示用的緯度
        let latitude = Double(lat)!
        let latitudeAbs = abs(latitude)
        let latitudeDirection = latitude >= 0 ? "北緯" : "南緯"
        
        // 顯示經緯度
        longitudeLabel.text = "\(longitudeDirection): \(longitudeAbs)°"
        latitudeLabel.text = "\(latitudeDirection): \(latitudeAbs)°"
    }
    
    func sendData(longitude: String, latitude: String){
        // 🔥 修正: 使用 shared 單例 + 實際的 JWT
        if let jwt = AuthManager.shared.getJWT() {
            MQTTUtils.shared.publishLocation(
                latitude: latitude,
                longitude: longitude,
                jwt: jwt
            )
        } else {
            // 🔥 如果沒有 JWT,使用測試 token 或顯示警告
            MQTTUtils.shared.publishLocation(
                latitude: latitude,
                longitude: longitude,
                jwt: "test_token"  // 或者不發送
            )
            mqttStatusLabel.text = "MQTT: 無 JWT"
            mqttStatusLabel.textColor = .systemOrange
            print("⚠️ 無 JWT Token,請先登入")
        }
    }
}

