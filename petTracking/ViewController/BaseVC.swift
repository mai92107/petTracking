//
//  BaseVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/12.
//

import UIKit

class BaseVC: UIViewController {
       
    override func viewDidLoad(){
        super.viewDidLoad()
        startCron()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(jwtChanged),
                                               name: .authStateChanged,
                                               object: nil)
        
    }

    @objc private func jwtChanged() {
        if !AuthManager.shared.isLoggedIn() {
            showNotLoginAlert(goTo: SceneNavigator.shared.switchToUnAuth)
        }else {
            showLoginSuccessAlert(goTo: SceneNavigator.shared.switchToAuth)
            
        }
    }
    
    
    func startCron(){
        Cron.shared.start()
    }
    
}
