//
//  LocationView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

final class LocationView: UIView{
    
    // MARK: - Constants
    private enum Location {
        static let defaultLatLabel = "緯度: ----------"
        static let defaultLngLabel = "經度: -----------"
    }
    
    // MARK: - UI Components
    private let latitudeLabel = PTLabel(text: Location.defaultLatLabel, with: .subtitle)
    private let longitudeLabel = PTLabel(text: Location.defaultLngLabel, with: .subtitle)

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
        addSubview(latitudeLabel)
        addSubview(longitudeLabel)
        
        let padding: CGFloat = 5
        
        NSLayoutConstraint.activate([
            longitudeLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            longitudeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            latitudeLabel.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: padding),
            latitudeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    // MARK: - Public Update Methods
    func updateLatitude(_ value: Double) {
        let direction = value >= 0 ? "北緯" : "南緯"
        latitudeLabel.resetLabel(text: "\(direction): \(abs(value))°", with: .subtitle)
    }

    func updateLongitude(_ value: Double) {
        let direction = value >= 0 ? "東經" : "西經"
        longitudeLabel.resetLabel(text: "\(direction): \(abs(value))°", with: .subtitle)
    }

    func resetLabels() {
        latitudeLabel.resetLabel(text: Location.defaultLatLabel, with: .subtitle)
        longitudeLabel.resetLabel(text: Location.defaultLngLabel, with: .subtitle)
    }
    
    func showLocationError(_ message: String) {
        latitudeLabel.text = message
        latitudeLabel.textColor = .systemRed
        longitudeLabel.text = ""
    }
}
