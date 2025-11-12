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

    // 未登入畫面
    func switchToUnAuth() {
        let homeVC = HomeVC()
        setRoot(homeVC)
    }

    // 已登入畫面
    func switchToAuth() {
        let homeVCAuth = HomeVCAuth()
        setRoot(homeVCAuth)
    }

    // 從目前頁面跳轉
    func goto(_ vc: UIViewController, from origin: UIViewController) {
        if let nav = origin.navigationController {
            // 檢查是否已存在該頁面
            if let existingVC = nav.viewControllers.first(where: { type(of: $0) == type(of: vc) }) {
                nav.popToViewController(existingVC, animated: true)
            } else {
                nav.pushViewController(vc, animated: true)
            }
        } else {
            // 若沒有 navigationController，就包一層新的
            let nav = UINavigationController(rootViewController: vc)
            origin.present(nav, animated: true)
        }
    }

    // 切換根頁面
    private func setRoot(_ vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil)
        window.makeKeyAndVisible()
    }
}

