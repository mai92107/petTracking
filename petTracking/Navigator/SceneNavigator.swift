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
    
    // 支援傳入 ViewController 類型
    func goto<T: UIViewController>(_ vcType: T.Type, from origin: UIViewController, slideFromLeft: Bool = true) {
        let vc = vcType.init()
        goto(vc, from: origin, slideFromLeft: slideFromLeft)
    }
    
    func goto(_ vc: UIViewController, from origin: UIViewController, slideFromLeft: Bool = true) {
        // 統一加返回按鈕
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backToHome)
        )
        
        if let nav = origin.navigationController {
            // 有 nav → push
            if let existingVC = nav.viewControllers.first(where: { type(of: $0) == type(of: vc) }) {
                nav.popToViewController(existingVC, animated: true)
            } else {
                nav.pushViewController(vc, animated: true)
            }
        } else {
            // 沒 nav → 包 nav
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            guard let window = origin.view.window else {
                origin.present(nav, animated: true)
                return
            }
            
            let transition = CATransition()
            transition.duration = 0.35
            transition.type = .push
//            transition.subtype = slideFromLeft ? .fromLeft : .fromRight       // 判斷左還右滑入
            transition.subtype = .fromRight
            window.layer.add(transition, forKey: kCATransition)
            window.rootViewController = nav
        }
    }
    
    // 返回 HomeVC
    @objc private func backToHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let homeVC = HomeVCAuth()
        let nav = UINavigationController(rootViewController: homeVC)
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = .push
        transition.subtype = .fromLeft // 返回動畫從右滑入
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = nav
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
