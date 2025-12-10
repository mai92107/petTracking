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
    
    private var isConnected = MQTTManager.shared.isConnect

    
    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupUI()
        if isConnected{
            getStatusInfo(device: DeviceConfig.deviceId)
        }
    }

    // MARK: - Config
    private func setupConfig(){
        MQTTManager.shared.delegate = self
    }
    
    // MARK: - Layout
    private func setupUI() {
        view.backgroundColor = .backgroundColor
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
    

}

extension DevStatusVC: MQTTManagerDelegate{
    func mqttStatusChanged(isConnected: Bool) {
        if isConnected {
            getStatusInfo(device: DeviceConfig.deviceId)
        }else{
            statusInfoLabel.updateStatus(online: false)
        }
    }
    
    func mqttMsgGet(topic: String, message: String) {
    }
    
    // TODO: 當為ADMIN時 跳出選擇裝置的匡
    private func getStatusInfo(device: String){
        Task { @MainActor in
            let response = await MQTTUtils.shared.publishDevStatusData(deviceId: device)

            switch response {
            case .success(let msg):
                statusInfoLabel.updateLastSeenLabel(time: msg.data!.lastSeen)
                statusInfoLabel.updateStatus(online: msg.data!.online)
            case .failure(let errorMsg):
                // 自動彈出後端錯誤訊息！
                showMessageAlert(title: "裝置狀態查詢失敗", message: errorMsg.message)

            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試"
                )
            case .rawResponse(let msg):
                print("rawResponse: " + msg)
            }
        }
    }
}


//#Preview{
//    DevStatusVC()
//}
