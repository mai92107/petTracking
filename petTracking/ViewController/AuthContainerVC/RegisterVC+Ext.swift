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
    
    private let actionButton = PTButton(title: "註冊")
    private let goLoginLabel = PTLabel(text: "已經有帳號？ 前往登入", with: .memo)

    
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
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.backgroundColor = .white
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let textView = PTVerticalStackView(in: 30, views: [usernameTextField, emailTextField, passwordTextField, firstnameTextField, lastnameTextField, nicknameTextField])
        scrollView.addSubview(textView)

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        view.addSubview(actionButton)
        view.addSubview(goLoginLabel)
        
        let vPadding: CGFloat = 120
        let hPadding: CGFloat = 50
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: vPadding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // ScrollView 中間區塊，高度一半
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hPadding),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hPadding),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            // textStack 綁定 scrollView
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hPadding),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hPadding),
            actionButton.bottomAnchor.constraint(equalTo: goLoginLabel.topAnchor, constant: -10),
            
            goLoginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goLoginLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -vPadding)
        ])
    }
}
extension RegisterVC: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension RegisterVC: PtButtonDelegate{
    func onClick() {
        let data: [String: String] = [
            "usernameTextField": usernameTextField.text ?? "",
            "emailTextField": emailTextField.text ?? "",
            "passwordTextField": passwordTextField.text ?? "",
            "firstnameTextField": firstnameTextField.text ?? "",
            "lastnameTextField": lastnameTextField.text ?? "",
            "nicknameTextField": nicknameTextField.text ?? ""
        ]
        print(data)
    }
}

#Preview {
    RegisterVC()
}
