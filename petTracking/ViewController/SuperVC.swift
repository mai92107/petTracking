//
//  AuthVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import UIKit

final class SuperVC<childView: BaseVC>: BaseVC {
       
    override func viewDidLoad(){
        super.viewDidLoad()
        setupLayout()
        
    }
    
    func setupLayout(){
        view.backgroundColor = .ptQuinary
        
        let loginVC = childView()
        addChild(loginVC)
        
        let loginView = loginVC.view!
        view.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.heightAnchor.constraint(equalTo: view.heightAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        

    }
}

#Preview {
    SuperVC<RegisterVC>()
//    SuperVC<LoginVC>()
}
