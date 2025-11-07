//
//  PTTextField.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

class PTTextField: UITextField{
    
    private let underline = CALayer()

    init(placeholder: String, with keyboardType: UIKeyboardType, isSecureText: Bool){
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.borderStyle = .none
        self.autocapitalizationType = .none
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureText
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.systemFont(ofSize: 28)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        underline.backgroundColor = UIColor.gray.cgColor
        layer.addSublayer(underline)
    }
    override func layoutSubviews() {
            super.layoutSubviews()
            // 每次 layout 時更新底線位置與大小
            underline.frame = CGRect(
                x: 0,
                y: bounds.height + 5,
                width: bounds.width,
                height: 1
            )
        }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        setUnderlineColor(isFocus: true)
        return result
    }
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        setUnderlineColor(isFocus: false)
        return result
    }
    func setUnderlineColor(isFocus: Bool) {
        let color = isFocus ? UIColor.black.cgColor : UIColor.gray.cgColor
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = underline.backgroundColor
        animation.toValue = color
        animation.duration = 0.25
        underline.add(animation, forKey: "colorChange")
        underline.backgroundColor = color
    }
}
#Preview {
    LoginVC()
}
