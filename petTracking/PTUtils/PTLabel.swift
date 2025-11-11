//
//  PTLabel.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//

import UIKit

enum PTLabelStyle {
    case title
    case subtitle
    case memo
}

protocol PTLabelDegate: AnyObject{
    func goto()
}

class PTLabel: UILabel {
    
    weak var ptDelegate: PTLabelDegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(text: String, with style: PTLabelStyle){
        super.init(frame: .zero)

        // 共同屬性
        self.text = text
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = .center
        
        // 風格
        switch style{
            case .title:
            self.textColor = .label
            self.font = .systemFont(ofSize: 32, weight: .bold)
            break
            
            case .subtitle:
            self.textColor = .secondaryLabel
            self.font = .systemFont(ofSize: 28, weight: .medium)
            break
            
            case .memo:
            self.textColor = .secondaryLabel
            self.font = .systemFont(ofSize: 15, weight: .semibold)
            break
        }
    }
    // 超連結Label
    init(text: String, color: UIColor, fontSize: CGFloat, in vc: UIViewController){
        super.init(frame: .zero)

        self.text = text
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        self.textAlignment = .center
        
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: color,
                .font: UIFont.systemFont(ofSize: fontSize, weight: .medium)
            ]
        )
        
        self.attributedText = attributedText
        
        // 提供連結
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoTarget))
        self.addGestureRecognizer(tap)
    }

    func resetLabel(text: String, with style: PTLabelStyle){
        self.text = text

        // 風格
        switch style{
            case .title:
            self.textColor = .label
            self.font = .systemFont(ofSize: 32, weight: .bold)
            break
            
            case .subtitle:
            self.textColor = .secondaryLabel
            self.font = .systemFont(ofSize: 28, weight: .medium)
            break
            
            case .memo:
            self.textColor = .secondaryLabel
            self.font = .systemFont(ofSize: 15, weight: .semibold)
            break
        }
    }
    
    @objc func gotoTarget(){
        ptDelegate?.goto()
    }
}
