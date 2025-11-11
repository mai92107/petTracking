//
//  PTStackView.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit

class PTHorizontalStackView: UIStackView {
    
    init(in padding: CGFloat, views: [UIView]) {
        super.init(frame: .zero)
        
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = padding
        self.translatesAutoresizingMaskIntoConstraints = false
        
        views.forEach{ self.addArrangedSubview($0) }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PTVerticalStackView: UIStackView {

    init(in padding: CGFloat, views: [UIView]) {
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.alignment = .fill
        self.spacing = padding
        self.translatesAutoresizingMaskIntoConstraints = false
        views.forEach{ self.addArrangedSubview($0) }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
