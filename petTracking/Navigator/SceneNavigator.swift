//
//  SceneNavigator.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/12.
//

import UIKit

final class SceneNavigator {
    static let shared = SceneNavigator()
    private init() {}

    func switchToUnAuth() {
        let homeVC = HomeVC()
        setRoot(homeVC)
    }

    func switchToAuth() {
        let homeVCAuth = HomeVCAuth()
        setRoot(homeVCAuth)
    }

    private func setRoot(_ vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .curveLinear,
                          animations: nil)
    }
}
