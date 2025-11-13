//
//  MqttStatusView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

final class DeviceStatusView: UIView {
    
    // MARK: - UI Components
    private let LastSeenLabel = PTLabel(text: "前次記錄時間: ----", with: .subtitle)
    private let StatusLabel = PTLabel(text: "在線狀況: ----", with: .subtitle)

    
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
        addSubview(LastSeenLabel)
        addSubview(StatusLabel)
        
        let padding: CGFloat = 5
                
        NSLayoutConstraint.activate([
            LastSeenLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            LastSeenLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            StatusLabel.topAnchor.constraint(equalTo: LastSeenLabel.bottomAnchor, constant: padding),
            StatusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    // MARK: - Public Update Methods
    
    func updateLastSeenLabel(time: String) {
        LastSeenLabel.text = "前次記錄時間: \n\(time)"
        LastSeenLabel.numberOfLines = 0 // 允許多行
    }
    func updateStatus(online: Bool) {
        StatusLabel.text = online ? "在線狀況: ✓" : "在線狀況: ᙮"
        StatusLabel.textColor = online ? .ptSecondary : .ptTertiary
    }
}
#Preview{
    DevStatusVC()
}
