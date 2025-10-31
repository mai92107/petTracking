//
//  LocationAlert.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/31.
//

import UIKit

class AlertManager {
    
    // MARK: - 定位權限提示
    static func showLocationPermissionAlert(
        on viewController: UIViewController,
        onCancel: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "需要定位權限",
            message: "請在「設定 > 隱私權與安全性 > 定位服務」中開啟本 App 的定位權限",
            preferredStyle: .alert
        )
        
        // 前往設定
        alert.addAction(UIAlertAction(title: "前往設定", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        // 取消
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
            onCancel?()
        })
        
        viewController.present(alert, animated: true)
    }
    
    // MARK: - 登入提示
    static func showLoginAlert(
        on viewController: UIViewController,
        onConfirm: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "需要登入",
            message: "請先登入以使用定位功能",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            onConfirm?()
        })
        
        viewController.present(alert, animated: true)
    }
    
    // MARK: - 定位失敗提示
    static func showLocationFailedAlert(
        on viewController: UIViewController,
        message: String = "無法取得位置資訊",
        onRetry: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "定位失敗",
            message: message,
            preferredStyle: .alert
        )
        
        if let retry = onRetry {
            alert.addAction(UIAlertAction(title: "重試", style: .default) { _ in
                retry()
            })
        }
        
        alert.addAction(UIAlertAction(title: "確定", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    // MARK: - 通用確認對話框
    static func showConfirmation(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "確定",
        cancelTitle: String = "取消",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            onConfirm()
        })
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            onCancel?()
        })
        
        viewController.present(alert, animated: true)
    }
    
    // MARK: - 通用訊息提示
    static func showMessage(
        on viewController: UIViewController,
        title: String,
        message: String,
        buttonTitle: String = "確定",
        onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
            onDismiss?()
        })
        
        viewController.present(alert, animated: true)
    }
}
extension UIViewController {
    
    /// 顯示定位權限提示
    func showLocationPermissionAlert(onCancel: (() -> Void)? = nil) {
        AlertManager.showLocationPermissionAlert(on: self, onCancel: onCancel)
    }
    
    /// 顯示登入提示
    func showLoginAlert(onConfirm: (() -> Void)? = nil) {
        AlertManager.showLoginAlert(on: self, onConfirm: onConfirm)
    }
    
    /// 顯示定位失敗提示
    func showLocationFailedAlert(message: String = "無法取得位置資訊", onRetry: (() -> Void)? = nil) {
        AlertManager.showLocationFailedAlert(on: self, message: message, onRetry: onRetry)
    }
}
