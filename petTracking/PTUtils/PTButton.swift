//
//  PTButton.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit

class PTButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let bgColor: UIColor = .white
        let textColor: UIColor = .black
        
        let pdTop: CGFloat = 10
        let pdLeft: CGFloat = 30
        let pdRight: CGFloat = 30
        let pdBottom: CGFloat = 10
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.baseBackgroundColor = bgColor
            config.baseForegroundColor = textColor
            config.cornerStyle = .medium

            // padding
            config.contentInsets = NSDirectionalEdgeInsets(top: pdTop, leading: pdLeft, bottom: pdBottom, trailing: pdRight)

            // 字體大小與粗體
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 30, weight: .bold)
                return outgoing
            }

            self.configuration = config
        } else {
            backgroundColor = bgColor
            setTitle(title, for: .normal)
            setTitleColor(textColor, for: .normal)

            // 字體大小與粗體
            titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)

            layer.cornerRadius = 15

            // padding
            contentEdgeInsets = UIEdgeInsets(top: pdTop, left: pdLeft, bottom: pdBottom, right: pdRight)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
