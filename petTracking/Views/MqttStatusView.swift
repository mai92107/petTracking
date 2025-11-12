//
//  MqttStatusView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

final class MqttStatusView: UIView {
    
    // MARK: - UI Components
    private let mqttGoStatusLabel = PTLabel(text: "MQTT-GO: ----", with: .subtitle)
    private let mqttUIKStatusLabel = PTLabel(text: "MQTT-UIK: ----", with: .subtitle)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(mqttGoStatusLabel)
        addSubview(mqttUIKStatusLabel)
        
        let padding: CGFloat = 5
        
        NSLayoutConstraint.activate([
            mqttGoStatusLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mqttGoStatusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            mqttUIKStatusLabel.topAnchor.constraint(equalTo: mqttGoStatusLabel.bottomAnchor, constant: padding),
            mqttUIKStatusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    // MARK: - Public Update Methods
    
    func updateMQTTGoStatus(status: String) {
        var isConnected = false
        if status == "連線正常"{
            isConnected = true
        }
        if status == "連線斷開"{
            isConnected = false
        }
        mqttGoStatusLabel.text = "MQTT-GO: \(status) \(isConnected ? "✓" : "᙮")"
        mqttGoStatusLabel.textColor = isConnected ? .ptSecondary : .ptTertiary
    }
    func updateMQTTUIKStatus(isConnected: Bool) {
        mqttUIKStatusLabel.text = isConnected ? "MQTT-UIK: 已連線 ✓" : "QTT-UIK: 未連線 ᙮"
        mqttUIKStatusLabel.textColor = isConnected ? .ptSecondary : .ptTertiary
    }

}
