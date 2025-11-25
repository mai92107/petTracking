//
//  PTTextFieldCollectionViewCell.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/25.
//
import UIKit

class TripViewCell: UICollectionViewCell {
    
    private let tripInfo = PTLabel(text: "", with: .memo)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        tripInfo.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tripInfo)
        
        let padding: CGFloat = 10

        NSLayoutConstraint.activate([
            tripInfo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            tripInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            tripInfo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            tripInfo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        contentView.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
    }
    

    func configure(time: String, distance: String, duration: String) {
        tripInfo.text = "\(time) - \(distance)km - \(duration)min"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//#Preview{
//    HomeVCAuth()
//}
