//
//  Timer.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/12.
//

import UIKit

final class Cron {
    static let shared = Cron()
    private var timer: Timer?

    private init() {}

    func start() {
        // 先停止舊的 timer
        stopChecking()
        
        // 建立新的 timer，每 30 秒檢查一次
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            // 檢查 jwt 狀態
            self?.checkJWT()
        }
    }
    
    func stopChecking() {
        timer?.invalidate()
        timer = nil
    }
    
    
    private func checkJWT() {
        if !AuthManager.shared.isLoggedIn() {
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
        }
    }
}
