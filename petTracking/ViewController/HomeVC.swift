//
//  HomeVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import UIKit

final class HomeVC: UIViewController{
    
    private let gotoLoginButton = PTButton(title: "前往登入", Vpadding: 15, Hpadding: 20)
    private let gotoRegisterButton = PTButton(title: "前往註冊", Vpadding: 15, Hpadding: 20)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupConfig()
        setupLayout()
    }
    
    func setupConfig(){
        gotoLoginButton.ptDelegate = self
        gotoRegisterButton.ptDelegate = self
    }
    
    func setupLayout(){
        let buttons = PTVerticalStackView(in: 20, views: [gotoLoginButton, gotoRegisterButton])
        
        view.backgroundColor = .ptQuaternary
        
        view.addSubview(buttons)
        
        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            buttons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            buttons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            buttons.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200)
        ])
    }
}

extension HomeVC: PtButtonDelegate{
    func onClick(_ sender: PTButton) {
        if sender == gotoLoginButton {
            print("Login button tapped")
            if let nav = navigationController {
                nav.pushViewController(LoginVC(), animated: true)
            }
            
        } else if sender == gotoRegisterButton {
            print("Register button tapped")
            if let nav = navigationController {
                nav.pushViewController(RegisterVC(), animated: true)
            }
        }
    }
}

#Preview{
    HomeVC()
}
