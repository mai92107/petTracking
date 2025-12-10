//
//  LoginVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//


import UIKit

final class RegisterVC: BaseFormVC {
    
    private let usernameTextField = PTTextField(placeholder: "帳號*", with: .default, isSecureText: false)
    private let emailTextField = PTTextField(placeholder: "信箱*", with: .emailAddress, isSecureText: false)
    private let passwordTextField = PTTextField(placeholder: "密碼*", with: .default, isSecureText: true)
    private let firstnameTextField = PTTextField(placeholder: "名字", with: .default, isSecureText: true)
    private let lastnameTextField = PTTextField(placeholder: "姓氏", with: .default, isSecureText: true)
    private let nicknameTextField = PTTextField(placeholder: "暱稱*", with: .default, isSecureText: true)
    
    private let actionButton = PTButton(title: "註冊", Vpadding: 15 ,Hpadding: 0, bgColor: .btColor, textColor: .lColor)
    private let goLoginLabel = PTLabel(text: "已經有帳號？", with: .memo)
    private lazy var goLoginAnchorLabel = PTLabel(text: " 前往登入", color: .secondaryLabel, fontSize: 15, in: self)
    
    override func viewDidLoad() {
        // 設定標題
        titleLabel.text = "註冊裝置"
        
        // 表單欄位
        formFields = [
            PTHorizontalStackView(in: 20, views: [usernameTextField, passwordTextField]),
            emailTextField,
            nicknameTextField,
            PTHorizontalStackView(in: 20, views: [firstnameTextField, lastnameTextField])
        ]
        
        // 按鈕
        formButtons = [actionButton]
        
        // 底部跳轉 Label
        gotoLabel = goLoginLabel
        gotoAnchorLabel = goLoginAnchorLabel
        
        super.viewDidLoad()
    }
    
    override func setupDelegates() {
        [usernameTextField, emailTextField, passwordTextField, firstnameTextField, lastnameTextField, nicknameTextField].forEach {
            $0.delegate = self
        }
        actionButton.ptDelegate = self
        goLoginAnchorLabel.ptDelegate = self
    }
}



extension RegisterVC: PTLabelDegate{
    func goto() {
        if let nav = navigationController {
            for vc in nav.viewControllers {
                if vc is LoginVC {
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
            // 如果不存在才 push
            nav.pushViewController(LoginVC(), animated: true)
        }
    }
}

extension RegisterVC: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension RegisterVC: PtButtonDelegate{
    func onClick(_ sender: PTButton) {
        let username = usernameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        let firstname = firstnameTextField.text
        let lastname = lastnameTextField.text
        let nickname = nicknameTextField.text
        Task{ @MainActor in
            let response = await MQTTUtils.shared.publishRegisterData(username: username!,
                                                                      email: email!,
                                                                      password: password!,
                                                                      firstname: firstname ?? "",
                                                                      lastname: lastname ?? "",
                                                                      nickname: nickname!)
            switch response {
            case .success(let msg):
                let jwt = msg.data!.token
                AuthManager.shared.setJwt(jwt)
                
            case .failure(let errorMsg):
                // 自動彈出後端錯誤訊息！
                showMessageAlert(title: "註冊失敗",message: errorMsg.message)
                
            case .timeout:
                showMessageAlert(title: "連線逾時",message: "請檢查網路後重試")
                
            case .rawResponse(let msg):
                print("rawResponse: " + msg)
            }
        }
    }
}

#Preview {
    RegisterVC()
}
