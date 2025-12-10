//
//  TrackingVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit
import CoreLocation

final class SysStatusVC: BaseVC {
    
    // MARK: - UI Components
    private let titleLabel = PTLabel(text: "System Status", with: .title)
    private let mqttStatusLabel = MqttStatusView()

    // MARK: - Properties
    private var isConnected = MQTTManager.shared.isConnect
    
    // MARK: - View Entrence
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupUI()
        mqttStatusLabel.updateMQTTUIKStatus(isConnected: isConnected)
        if isConnected{
            getGoMqttStatus()
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
        view.addSubview(mqttStatusLabel)
        
        let padding: CGFloat = 40
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            
            mqttStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mqttStatusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            mqttStatusLabel.heightAnchor.constraint(equalToConstant: 100)

        ])
    }
}

extension SysStatusVC: MQTTManagerDelegate{
    func mqttMsgGet(topic: String, message: String) {
    }
    
    func mqttStatusChanged(isConnected: Bool) {
        mqttStatusLabel.updateMQTTUIKStatus(isConnected: isConnected)
        if isConnected {
            getGoMqttStatus()
        }else{
            mqttStatusLabel.updateMQTTGoStatus(status: "連線斷開")
        }

    }
    func getGoMqttStatus(){
        Task { @MainActor in
            let response = await MQTTUtils.shared.publishSysStatusData()

            switch response {
            case .success(let msg):
                mqttStatusLabel.updateMQTTGoStatus(status: msg.data!.mqtt_status)
            case .failure(let errorMsg):
                // 自動彈出後端錯誤訊息！
                showMessageAlert(title: "系統狀態查詢失敗", message: errorMsg.message)

            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試"
                )
            case .rawResponse(let msg):
                print("rawResponse: " + msg)
            }
        }
    }
}

//
//#Preview{
//    SysStatusVC()
//}
