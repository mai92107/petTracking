//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class DevStatusVC: BaseVC {
    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "Device Status", with: .title)
    private let statusInfoLabel = DeviceStatusView()
    
    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupUI()
        getStatusInfo()
    }

    // MARK: - Config
    private func setupConfig(){
    }
    
    // MARK: - Layout
    private func setupUI() {
        view.backgroundColor = .ptQuaternary
        
        view.addSubview(titleLabel)
        view.addSubview(statusInfoLabel)
        
        let padding: CGFloat = 40
                
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            
            statusInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusInfoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            statusInfoLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
    private func getStatusInfo(){
//        Task { @MainActor in
//            let response = await MQTTUtils.shared.publishDevStatusData()
//
//            switch response {
//            case .success(let msg):
//                statusInfoLabel.updateLastSeenLabel(time: msg.data.lastSeen)
//                statusInfoLabel.updateStatus(isOnline: msg.data.online)
//            case .failure(let errorMsg):
//                // 自動彈出後端錯誤訊息！
//                showMessageAlert(title: "系統狀態查詢失敗", message: errorMsg.message)
//
//            case .timeout:
//                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試"
//                )
//            case .rawResponse(let msg):
//                print("rawResponse: " + msg)
//            }
//        }
        
        statusInfoLabel.updateLastSeenLabel(time: "2025-11-12 12:21:55")
        statusInfoLabel.updateStatus(isOnline: "true")
    }
}


#Preview{
    DevStatusVC()
}
