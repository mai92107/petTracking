//
//  BaseFormVC.swift
//  petTracking
//
//  Created by shue on 2025/12/10.
//

import UIKit

class BaseFormVC: BaseVC {
    
    // UI Elements
    let titleLabel = PTLabel(text: "", with: .title)
    
    // 表單欄位（TextField 或其他 UIView）
    var formFields: [UIView] = []
    
    // 按鈕或其他可互動元素（UIView）
    var formButtons: [UIView] = []
    
    var gotoLabel: PTLabel?
    var gotoAnchorLabel: PTLabel?
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        setupLayout()
        setupDelegates()
    }
    
    // Override in subclass
    func setupDelegates() {
        // 子類別可 override 來設定 delegate
    }
    
    func setupLayout() {
        // 組合 formStack
        let formStack = PTVerticalStackView(in: 20, views: formFields + formButtons)
            .withBackground(
                color: UIColor(white: 1, alpha: 0.7),
                cornerRadius: 25,
                Vpadding: 40,
                Hpadding: 15
            )
        
        let containerView = ShadowContainerView(content: formStack)
        
        formStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            formStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            formStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        
        if let gotoLabel = gotoLabel, let gotoAnchorLabel = gotoAnchorLabel {
            let gotoStack = PTHorizontalStackView(in: 5, views: [gotoLabel, gotoAnchorLabel])
            view.addSubview(gotoStack)
            
            NSLayoutConstraint.activate([
                gotoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                gotoStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
            ])
        }
        
        let hPadding: CGFloat = 30
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hPadding),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hPadding)
        ])
    }
}
