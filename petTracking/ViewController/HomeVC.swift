//
//  HomeVC.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import UIKit
import SceneKit
import SwiftUI  // 只用來做 Canvas 預覽

final class HomeVC: BaseVC{
    
    private let gotoLoginButton = PTButton(title: "前往登入", Vpadding: 15, Hpadding: 10, bgColor: .btColor, textColor: .lColor)
    private let gotoRegisterButton = PTButton(title: "前往註冊", Vpadding: 15, Hpadding: 10, bgColor: .btColor, textColor: .lColor)
    
    private var sceneView: SCNView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupConfig()
        setupLayout()
//        setup3DEarth()
    }
    
    func setupConfig(){
        gotoLoginButton.ptDelegate = self
        gotoRegisterButton.ptDelegate = self
    }
    
    func setupLayout(){
        view.backgroundColor = .backgroundColor
        let buttonsStack = PTVerticalStackView(in: 20, views: [gotoLoginButton, gotoRegisterButton])
        view.addSubview(buttonsStack)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        // 圖釘2
        let pinIcon2 = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        pinIcon2.tintColor = .iconColor
        pinIcon2.contentMode = .scaleAspectFit
        pinIcon2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinIcon2)
        
        NSLayoutConstraint.activate([
            pinIcon2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinIcon2.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            pinIcon2.widthAnchor.constraint(equalToConstant: 50),
            pinIcon2.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
//    func setup3DEarth() {
//        let sceneView = EarthNodeFactory.makeEarthView()
//        self.sceneView = sceneView
//        view.addSubview(sceneView)
//        view.sendSubviewToBack(sceneView)
//
//        NSLayoutConstraint.activate([
//            sceneView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
//            sceneView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
//            sceneView.heightAnchor.constraint(equalTo: sceneView.widthAnchor, multiplier: 0.9)
//        ])
//    }

}

extension HomeVC: PtButtonDelegate{
    func onClick(_ sender: PTButton) {
        if sender == gotoLoginButton {
            print("Login button tapped")
            if let nav = navigationController {
                nav.pushViewController(LoginVC(), animated: true)
            }
        } else if sender == gotoRegisterButton {
            print("Register button tapped")
            if let nav = navigationController {
                nav.pushViewController(RegisterVC(), animated: true)
            }
        }
    }
}

// SwiftUI Preview
struct HomeVC_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            HomeVC()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
// UIKit -> SwiftUI 轉接器
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let makeVC: () -> ViewController
    init(_ makeVC: @escaping () -> ViewController) { self.makeVC = makeVC }
    
    func makeUIViewController(context: Context) -> ViewController {
        return makeVC()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

//#Preview {
//    HomeVC()
//}
