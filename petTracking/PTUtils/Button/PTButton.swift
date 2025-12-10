//
//  PTButton.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit

protocol PtButtonDelegate: AnyObject {
    func onClick(_ sender: PTButton)
}

class PTButton: UIButton {
    
    weak var ptDelegate: PtButtonDelegate?

    init(title: String, Vpadding: CGFloat, Hpadding: CGFloat, bgColor: UIColor = .ptPrimary, textColor: UIColor = .ptQuinary) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

//        let bgColor: UIColor = .ptPrimary
//        let textColor: UIColor = .ptQuinary
        
        let pdTop: CGFloat = Vpadding
        let pdLeft: CGFloat = Hpadding
        let pdRight: CGFloat = Hpadding
        let pdBottom: CGFloat = Vpadding
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.baseBackgroundColor = bgColor
            config.baseForegroundColor = textColor
            config.cornerStyle = .capsule

            // padding
            config.contentInsets = NSDirectionalEdgeInsets(top: pdTop, leading: pdLeft, bottom: pdBottom, trailing: pdRight)

            // 字體大小與粗體
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                return outgoing
            }

            self.configuration = config
        } else {
            backgroundColor = bgColor
            setTitle(title, for: .normal)
            setTitleColor(textColor, for: .normal)

            // 字體大小與粗體
            titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)

            layer.cornerRadius = 15
            
            // padding
            contentEdgeInsets = UIEdgeInsets(top: pdTop, left: pdLeft, bottom: pdBottom, right: pdRight)
        }
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(){
        ptDelegate?.onClick(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

