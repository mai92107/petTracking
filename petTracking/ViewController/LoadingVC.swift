//
//  EntranceVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/11.
//

import UIKit

class LoadingViewController: UIViewController {

    private let progressView = UIProgressView(progressViewStyle: .default)
    private var progress: Float = 0.0
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupProgressView()
        startProgress()
    }

    private func setupProgressView() {
        view.backgroundColor = .ptQuaternary
        progressView.frame = CGRect(x: 40, y: view.frame.height * 2/3, width: view.frame.width - 80, height: 20)
        
        progressView.progress = 0.0
        progressView.tintColor = .ptQuaternary
        view.addSubview(progressView)
    }

    private func startProgress() {
        // 模擬進度，每0.05秒增加0.01
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.01
            self.progressView.setProgress(self.progress, animated: true)

            if self.progress >= 1.0 {
                self.showMainViewController()
                self.timer?.invalidate()
            }
        }
    }


    func showMainViewController() {
        let rootVC: UIViewController
        if !AuthManager.shared.isLoggedIn() {
            // 未登入，顯示 HomeVC
            rootVC = HomeVC()
        } else {
            // 已登入，顯示 HomeVCAuth
            rootVC = HomeVCAuth()
        }
        let nav = UINavigationController(rootViewController: rootVC)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first {
               window.rootViewController = nav
               UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
           }
    }
}
