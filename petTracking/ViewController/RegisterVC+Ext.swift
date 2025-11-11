//
//  LoginVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//


import UIKit

final class RegisterVC: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel = PTLabel(text: "註冊裝置", with: .title)
    
    private let usernameTextField = PTTextField(placeholder: "帳號*", with: .default, isSecureText: false)
    private let emailTextField = PTTextField(placeholder: "信箱*", with: .emailAddress, isSecureText: false)
    private let passwordTextField = PTTextField(placeholder: "密碼*", with: .default, isSecureText: true)
    private let firstnameTextField = PTTextField(placeholder: "名字", with: .default, isSecureText: true)
    private let lastnameTextField = PTTextField(placeholder: "姓氏", with: .default, isSecureText: true)
    private let nicknameTextField = PTTextField(placeholder: "暱稱*", with: .default, isSecureText: true)
    
    private let actionButton = PTButton(title: "註冊", Vpadding: 15 ,Hpadding: 0)
    private let goLoginLabel = PTLabel(text: "已經有帳號？", with: .memo)
    private lazy var goLoginAnchorLabel = PTLabel(text: " 前往登入", color: .secondaryLabel, fontSize: 15, in: self)

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupLayout()
    }
    
    // MARK: - Config
    private func setupConfig(){
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        nicknameTextField.delegate = self
        actionButton.ptDelegate = self
        goLoginAnchorLabel.ptDelegate = self
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.backgroundColor = .ptQuaternary
        
        let accountView = PTHorizontalStackView(in: 20, views: [usernameTextField, passwordTextField])

        let nameView = PTHorizontalStackView(in: 20, views: [firstnameTextField, lastnameTextField])

        let formView = PTVerticalStackView(in: 30, views: [accountView, emailTextField, nicknameTextField, nameView, actionButton]).withBackground(color: UIColor(white: 1, alpha: 0.7), cornerRadius: 25, Vpadding: 40, Hpadding: 15)

        let gotoLabel = PTHorizontalStackView(in: 5, views: [goLoginLabel, goLoginAnchorLabel])

        view.addSubview(titleLabel)
        view.addSubview(formView)
        view.addSubview(gotoLabel)
        
        let hPadding: CGFloat = 30
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            formView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hPadding),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hPadding),
            
            gotoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gotoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        ])
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
                print("註冊成功: \(msg)")
                navigateToHomeAuth()

            case .failure(let errorMsg):
                // 自動彈出後端錯誤訊息！
                CommonAlertManager.showMessage(
                    on: self,
                    title: "註冊失敗",
                    message: errorMsg
                )

            case .timeout:
                CommonAlertManager.showMessage(
                    on: self,
                    title: "連線逾時",
                    message: "請檢查網路後重試"
                )
            case .rawSuccess(let msg):
                print("rawSuccess: " + msg)
            }
        }
    }
    
    func navigateToHomeAuth(){
        if let nav = navigationController {
            nav.pushViewController(HomeVCAuth(), animated: true)
        }
    }
}

//#Preview {
//    RegisterVC()
//}
