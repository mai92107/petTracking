//
//  MqttStatusView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

final class MqttStatusView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let defaultMQTTLabel = "MQTT: 未連線"
    }
    
    // MARK: - UI Components
    private let mqttStatusLabel = PTLabel(text: Constants.defaultMQTTLabel, with: .subtitle)
    
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
        addSubview(mqttStatusLabel)
        
        let padding: CGFloat = 5
        
        NSLayoutConstraint.activate([
            mqttStatusLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mqttStatusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    // MARK: - Public Update Methods
    
    func updateMQTTStatus(isConnected: Bool) {
        mqttStatusLabel.text = isConnected ? "MQTT: 已連線 ✓" : "MQTT: 未連線 ᙮"
        mqttStatusLabel.textColor = isConnected ? .ptSecondary : .ptTertiary
    }
    
    func showMQTTError() {
        mqttStatusLabel.text = "MQTT: 未登入"
        mqttStatusLabel.textColor = .systemRed
    }
}
