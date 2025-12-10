//
//  LoginVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//


import UIKit
import LocalAuthentication

final class LoginVC: BaseFormVC {
    
    private let accountTextField = PTTextField(placeholder: "帳戶", with: .emailAddress, isSecureText: false)
    private let passwordTextField = PTTextField(placeholder: "密碼", with: .default, isSecureText: true)
    private let actionLoginButton = PTButton(title: "登入", Vpadding: 15, Hpadding:10, bgColor: .btColor, textColor: .lColor)
    private let actionGoogleButton = PTButton(title: "透過google帳戶登入", Vpadding: 15, Hpadding:10, bgColor: .btColor, textColor: .lColor)
    private let textORLabel = PTLabel(text: "or", with: .memo)
    private let goRegisterLabel = PTLabel(text: "沒有帳號？", with: .memo)
    private lazy var goRegisterAnchorLabel = PTLabel(text: " 前往註冊", color: .secondaryLabel, fontSize: 15, in: self)
    
    override func viewDidLoad() {
        titleLabel.text = "裝置登入"
        formFields = [accountTextField, passwordTextField]
        formButtons = [
            PTVerticalStackView(in: 30, views: [actionLoginButton, textORLabel, actionGoogleButton])
        ]
        gotoLabel = goRegisterLabel
        gotoAnchorLabel = goRegisterAnchorLabel
        
        super.viewDidLoad()
        authenticateWithBiometrics()
    }
    
    override func setupDelegates() {
        [accountTextField, passwordTextField].forEach { $0.delegate = self }
        [actionLoginButton, actionGoogleButton].forEach { $0.ptDelegate = self }
        goRegisterAnchorLabel.ptDelegate = self
    }
}


extension LoginVC{
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        // 檢查Keychain是否已經有帳號密碼
        if KeychainHelper.shared.get("username") == nil || KeychainHelper.shared.get("password") == nil{
            return
        }
        
        // 檢查裝置是否支援生物辨識
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "請使用 Face ID / Touch ID 登入"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authError in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if success {
                        print("生物辨識登入成功")
                        if let username = KeychainHelper.shared.get("username"),
                           let password = KeychainHelper.shared.get("password") {
                            self.login(username: username, password: password)
                        }
                    } else {
                        let message = authError?.localizedDescription ?? "登入失敗"
                        self.showMessageAlert(title: "驗證失敗", message: message)
                    }
                }
            }
        } else {
            let message = error?.localizedDescription ?? "裝置不支援生物辨識"
            showMessageAlert(title: "錯誤", message: message)
        }
    }
    
    private func login(username: String, password: String) {
        Task { @MainActor in
            let response = await MQTTUtils.shared.publishLoginData(username: username, password: password)
            
            switch response {
            case .success(let msg):
                print("登入成功")
                let jwt = msg.data!.token
                let role = msg.data!.identity
                AuthManager.shared.setJwt(jwt)
                AuthManager.shared.setRole(role)
                // 可選：導向主頁
            case .failure(let errorMsg):
                showMessageAlert(title: "登入失敗", message: errorMsg.message)
            case .timeout:
                showMessageAlert(title: "連線逾時", message: "請檢查網路後重試")
            case .rawResponse(let msg):
                print("rawResponse: " + msg)
            }
        }
    }
}

extension LoginVC: PTLabelDegate{
    func goto() {
        if let nav = navigationController {
            for vc in nav.viewControllers {
                if vc is RegisterVC {
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
            // 如果不存在才 push
            nav.pushViewController(RegisterVC(), animated: true)
        }
    }
}

extension LoginVC: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginVC: PtButtonDelegate {
    func onClick(_ sender: PTButton) {
        guard let username = accountTextField.text else {
            showMessageAlert(title: "請輸入使用者帳戶", message: "")
            return
        }
        guard let password = passwordTextField.text else {
            showMessageAlert(title: "請輸入密碼", message: "")
            return
        }

        KeychainHelper.shared.save("username", value: username)
        KeychainHelper.shared.save("password", value: password)
        
        login(username: username, password: password)
    }
}

#Preview {
    LoginVC()
}
