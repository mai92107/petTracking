//
//  BTButton.swift
//  petTracking
//
//  Created by shue on 2025/12/5.
//

import UIKit

class BentoButtonColor: UIButton {

    static let colorHexes = [
        "#D6CFC4", "#C8C6B8", "#BFB9A8", "#A9A29C", "#C4B7A6",
        "#BABDC2", "#BEBFC2", "#C1BFB3", "#C9C5BE"
    ]

}
// BTButton 只管理 UI，並不處理跳轉邏輯，icon & title 是 UI 顯示層，而不是資料層
class BTButton: UIControl {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupShadow()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 將資料層傳入 UI 層顯示
    func configure(icon: String, title: String, color: UIColor) {
        backgroundColor = color
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
    }
    
    private func setupView() {
        layer.cornerRadius = 18
        layer.masksToBounds = false
        
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .black.withAlphaComponent(0.7)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isUserInteractionEnabled = false
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black.withAlphaComponent(0.8)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
    }
    
    private func setupGesture() {
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }
    
    @objc private func touchDown() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.layer.shadowOpacity = 0.07
        }
    }
    
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.transform = .identity
            self.layer.shadowOpacity = 0.12
        }
    }
}
