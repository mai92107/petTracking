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
    private let actionButton = PTButton(title: "登入")
    private let goRegisterLabel = PTLabel(text: "沒有帳號？ 前往註冊", with: .memo)

    
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
        actionButton.ptDelegate = self
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.backgroundColor = .white

        let textView = PTVerticalStackView(in: 30, views: [accountTextField, passwordTextField])
                
        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(actionButton)
        view.addSubview(goRegisterLabel)
        
        let vPadding: CGFloat = 120
        let hPadding: CGFloat = 50
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: vPadding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hPadding),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hPadding),
            
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hPadding),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hPadding),
            actionButton.bottomAnchor.constraint(equalTo: goRegisterLabel.topAnchor, constant: -10),
            
            goRegisterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goRegisterLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -vPadding)
        ])
    }
}

extension LoginVC: UITextFieldDelegate{ 
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginVC: PtButtonDelegate{
    func onClick() {
        let data: [String: String] = [
            "account": accountTextField.text ?? "",
            "password": passwordTextField.text ?? ""
        ]
        print(data)
    }
}


#Preview {
    LoginVC()
}
