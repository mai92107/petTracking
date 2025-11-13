//
//  HomeVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import UIKit

final class HomeVCAuth: BaseVC{
    
    private let gotoTrackingButton = PTButton(title: "裝置定位", Vpadding: 15, Hpadding: 20)
    private let gotoDeviceStatusButton = PTButton(title: "裝置狀態", Vpadding: 15, Hpadding: 20)
    private let gotoSystemStatusButton = PTButton(title: "系統狀態", Vpadding: 15, Hpadding: 20)
    private let gotoLogoutButton = PTButton(title: "登出裝置", Vpadding: 15, Hpadding: 20)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupConfig()
        setupLayout()
    }
    
    func setupConfig(){
        gotoTrackingButton.ptDelegate = self
        gotoDeviceStatusButton.ptDelegate = self
        gotoSystemStatusButton.ptDelegate = self
        gotoLogoutButton.ptDelegate = self
    }
    
    func setupLayout(){
        let buttons = PTVerticalStackView(in: 20, views: [gotoTrackingButton, gotoDeviceStatusButton,gotoSystemStatusButton, gotoLogoutButton])
        
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

extension HomeVCAuth: PtButtonDelegate{
    func onClick(_ sender: PTButton) {
        switch sender{
        case gotoTrackingButton:
            print("tracking button tapped")
            if let nav = navigationController {
                nav.pushViewController(TrackingVC(), animated: true)
            }
            
        case gotoDeviceStatusButton:
            print("device status button tapped")
            if let nav = navigationController {
                nav.pushViewController(DevStatusVC(), animated: true)
            }
        case gotoSystemStatusButton:
            print("system status button tapped")
            if let nav = navigationController {
                nav.pushViewController(SysStatusVC(), animated: true)
            }
        case gotoLogoutButton:
            print("logout button were tapped")
            AuthManager.shared.logout()
        default:
            print("Error unknown button were tapped!")
        }
    }
}
