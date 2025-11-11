//
//  UIView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import UIKit

extension UIView {
    func withBackground(color: UIColor, cornerRadius: CGFloat, Vpadding: CGFloat, Hpadding: CGFloat) -> UIView {
        let container = UIView()
        container.backgroundColor = color
        container.layer.cornerRadius = cornerRadius
        container.layer.masksToBounds = true
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.layer.shadowRadius = 8
        container.addSubview(self)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: container.topAnchor, constant: Vpadding),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Hpadding),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Hpadding),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Vpadding)
        ])
        return container
    }
}
