//
//  LocationAlert.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/31.
//

import UIKit

class CommonAlertManager {
    
    private init(){}
    
    static let shared = CommonAlertManager()
    
    func showLoginSuccessAlert(
        on viewController: UIViewController, _ completion: @escaping()->Void ){
            self.showMessage(on: viewController, title: "成功登入", message: "", onDismiss: completion)
    }
    
    func showNeedLoginAlert(
        on viewController: UIViewController, _ completion: @escaping()->Void ){
            self.showMessage(on: viewController, title: "前往登入", message: "", onDismiss: completion)
    }
    
    
    // MARK: - 通用確認對話框
    func showConfirmation(
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
    func showMessage(
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
    
    /// 顯示未登入
    func showNotLoginAlert(goTo: @escaping(() -> Void)) {
        CommonAlertManager.shared.showNeedLoginAlert(on: self, goTo)
    }
    
    /// 顯示成功登入
    func showLoginSuccessAlert(goTo: @escaping(() -> Void)) {
        CommonAlertManager.shared.showLoginSuccessAlert(on: self, goTo)
    }
    
    /// 顯示失敗提示
    func showFailedMessageAlert(message: String, onRetry: (() -> Void)? = nil) {
        CommonAlertManager.shared.showMessage(on: self, title: "發生錯誤", message: message)
    }
    
    /// 顯示提示
    func showMessageAlert(title: String, message: String, onRetry: (() -> Void)? = nil) {
        CommonAlertManager.shared.showMessage(on: self, title: title, message: message)
    }
    
    /// 顯示確認提示
    func showConfirmMessageAlert(title: String, message: String, onConfirm: (() -> Void)? = nil) {
        CommonAlertManager.shared.showConfirmation(on: self, title: title, message: message, onConfirm: onConfirm!)
    }
}
