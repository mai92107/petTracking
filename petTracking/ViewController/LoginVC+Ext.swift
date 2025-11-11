//
//  LoginVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//


import UIKit

final class LoginVC: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel = PTLabel(text: "裝置登入", with: .title)
    private let accountTextField = PTTextField(placeholder: "帳戶", with: .emailAddress, isSecureText: false)
    private let passwordTextField = PTTextField(placeholder: "密碼", with: .default, isSecureText: true)
    private let actionLoginButton = PTButton(title: "登入", Vpadding: 15, Hpadding:10)
    private let actionGoogleButton = PTButton(title: "透過google帳戶登入", Vpadding: 15, Hpadding:10)
    private let textORLabel = PTLabel(text: "or", with: .memo)
    private let goRegisterLabel = PTLabel(text: "沒有帳號？", with: .memo)
    private lazy var goRegisterAnchorLabel = PTLabel(text: " 前往註冊", color: .secondaryLabel, fontSize: 15, in: self)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfig()
        setupLayout()

    }
    
    // MARK: - Config
    private func setupConfig(){
        accountTextField.delegate = self
        passwordTextField.delegate = self
        actionLoginButton.ptDelegate = self
        actionGoogleButton.ptDelegate = self
        goRegisterAnchorLabel.ptDelegate = self
    }
    
    private func setupLayout() {
        view.backgroundColor = .ptQuaternary
        
        let buttons = PTVerticalStackView(in: 30, views: [actionLoginButton,textORLabel,actionGoogleButton])

        let formView = PTVerticalStackView(in: 30, views: [accountTextField, passwordTextField, buttons]).withBackground(color: UIColor(white: 1, alpha: 0.7), cornerRadius: 25, Vpadding: 40, Hpadding: 15)
        
        let gotoLabel = PTHorizontalStackView(in: 2, views: [goRegisterLabel, goRegisterAnchorLabel])

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

extension LoginVC: PtButtonDelegate{
    func onClick(_ sender: PTButton) {
        MQTTUtils.shared.publishLoginData(username: accountTextField.text ?? "", password: passwordTextField.text ?? "")
    }
}




#Preview {
    LoginVC()
}
