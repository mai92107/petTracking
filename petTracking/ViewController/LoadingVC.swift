//
//  EntranceVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/11.
//

import UIKit

class LoadingViewController: BaseVC {

    private let progressView = UIProgressView(progressViewStyle: .default)
    private var progress: Float = 0.0
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupProgressView()
        startProgress(showMainViewController)
    }

    private func setupProgressView() {
        view.backgroundColor = .ptQuaternary
        progressView.frame = CGRect(x: 40, y: view.frame.height * 2/3, width: view.frame.width - 80, height: 20)
        
        progressView.progress = 0.0
        progressView.tintColor = .ptQuaternary
        view.addSubview(progressView)
    }

    private func startProgress(_ completion: @escaping()->Void) {
        // 模擬進度，每0.05秒增加0.01
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.01
            self.progressView.setProgress(self.progress, animated: true)

            if self.progress >= 1.0 {
                completion()
                self.timer?.invalidate()
            }
        }
    }


    func showMainViewController() {
        if !AuthManager.shared.isLoggedIn() {
            SceneNavigator.shared.switchToUnAuth()
        } else {
            SceneNavigator.shared.switchToAuth()
            print(AuthManager.shared.getJWT()!)
        }
    }
}
