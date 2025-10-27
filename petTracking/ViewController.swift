//
//  ViewController.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let button = PTButton(title: "開始定位")
    let latitudeLabel = PTLabel(text: "經度: ", with: .subtitle)
    let longitudeLabel = PTLabel(text: "緯度: ", with: .subtitle)
    
    let recorderInterval: TimeInterval = 0.5
    
    let locationManager = CLLocationManager()
    var updateTimer: Timer?
    var isTracking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定 CLLocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        view.backgroundColor = .systemCyan
        
        button.addTarget(self, action: #selector(toggleTracking), for: .touchUpInside)

        
        let title = PTLabel(text: "Pet Tracking System", with: .title)
        
        let horizontalStackView: UIStackView = PTHorizontalStackView(views: [latitudeLabel, longitudeLabel])
        let verticalStackView: UIStackView = PTVerticalStackView(views: [title, horizontalStackView, button])

        view.addSubview(verticalStackView)
        
        let padding: CGFloat = 40
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
        ])
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
        button.setTitle("停止定位", for: .normal)
        
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
        button.setTitle("開始定位", for: .normal)
        
        updateTimer?.invalidate()
        updateTimer = nil
        locationManager.stopUpdatingLocation()
    }

}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 經度取前 5 位（含整數部分與小數部分）
        let longitudeString = String(format: "%.2f", location.coordinate.longitude) // 例如 121.56
        // 緯度取前 4 位
        let latitudeString = String(format: "%.2f", location.coordinate.latitude) // 例如 24.12

        latitudeLabel.text = "經度: \(longitudeString)"
        longitudeLabel.text = "緯度: \(latitudeString)"

        // 取得定位後停止更新，節省電量
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失敗: \(error.localizedDescription)")
    }
}

