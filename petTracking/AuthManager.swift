//
//  AuthManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private let jwtKey = "userJWT"
    
    private init() {}
    
    // 儲存 JWT
    func saveJWT(_ token: String) {
        UserDefaults.standard.set(token, forKey: jwtKey)
        print("✅ JWT 已儲存")
    }
    
    // 取得 JWT
    func getJWT() -> String? {
        return UserDefaults.standard.string(forKey: jwtKey)
    }
    
    // 清除 JWT
    func clearJWT() {
        UserDefaults.standard.removeObject(forKey: jwtKey)
        print("🗑️ JWT 已清除")
    }
    
    // 檢查是否已登入
    func isLoggedIn() -> Bool {
        return getJWT() != nil
    }
}
