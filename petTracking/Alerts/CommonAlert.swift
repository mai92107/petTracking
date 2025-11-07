//
//  LocationAlert.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/31.
//

import UIKit

class CommonAlertManager {
    
    // MARK: - 登入提示
    static func showLoginAlert(
        on viewController: UIViewController,
        onConfirm: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "需要登入",
            message: "請先登入以使用指定功能",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            onConfirm?()
        })
        
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
    func showNotLoginAlert(onCancel: (() -> Void)? = nil) {
        CommonAlertManager.showLoginAlert(on: self)
    }
    
    /// 顯示失敗提示
    func showFailedMessageAlert(message: String, onRetry: (() -> Void)? = nil) {
        showMessageAlert(title: "發生錯誤", message: message)
    }
    
    /// 顯示提示
    func showMessageAlert(title: String, message: String, onRetry: (() -> Void)? = nil) {
        CommonAlertManager.showMessage(on: self, title: title, message: message)
    }
    
    /// 顯示確認提示
    func showConfirmMessageAlert(title: String, message: String, onConfirm: (() -> Void)? = nil) {
        CommonAlertManager.showConfirmation(on: self, title: title, message: message, onConfirm: onConfirm!)
    }
}
