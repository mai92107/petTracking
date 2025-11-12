//
//  AppDelegate.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/22.
//
//┌───────────────────────────────────────────────────┐
//│ App 啟動 (iOS 系統載入 App)                         │
//└────────────────┬──────────────────────────────────┘
//                 ↓
//┌───────────────────────────────────────────────────┐
//│ application(_:didFinishLaunchingWithOptions:)     │
//│ 🔹 App 啟動完成，可做初始化設定                        │
//│ 🔹 設定第三方服務、Firebase、推播、UI外觀等             │
//│ ✅ 通常是 App 的進入點                               │
//└────────────────┬──────────────────────────────────┘
//                 ↓
//┌───────────────────────────────────────────────────┐
//│ application(_:configurationForConnecting:options:)│
//│ 🔹 系統準備建立新的 Scene                            │
//│ 🔹 回傳 UISceneConfiguration                       │
//│ 🔹 一個 App 可以有多個 Scene（例如多視窗）             │
//└────────────────┬──────────────────────────────────┘
//                 ↓
//┌──────────────────────────────────────────────────┐
//│ （交給 SceneDelegate 管理每個 Scene 的生命週期）      │
//│ → SceneDelegate.scene(_:willConnectTo:) 開始執行   │
//└────────────────┬─────────────────────────────────┘
//                 ↓
//┌──────────────────────────────────────────────────┐
//│ application(_:didDiscardSceneSessions:)          │
//│ 🔹 當使用者關閉某個 Scene 時觸發                     │
//│ 🔹 可在這裡釋放 Scene 相關資源                       │
//└──────────────────────────────────────────────────┘


import UIKit

@main // 程式進入點
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("✅ App 初始化完成！！！")
        MQTTManager.shared.startConnect()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

