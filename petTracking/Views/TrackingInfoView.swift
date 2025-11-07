//
//  TrackingInfoView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

final class TrackingInfoView: UIView {
    
    // MARK: - UI Components
    let locationLabel = LocationView()
    let mqttStatusLabel = MqttStatusView()
    
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
        addSubview(locationLabel)
        addSubview(mqttStatusLabel)
        
        let padding: CGFloat = 5
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationLabel.heightAnchor.constraint(equalToConstant: 80),
            
            mqttStatusLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: padding),
            mqttStatusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}
