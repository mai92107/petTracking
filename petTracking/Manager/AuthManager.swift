//
//  AuthManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//
import Foundation

class AuthManager {
    static let shared = AuthManager()

    private let jwtKey = "jwt_token"
    private let defaults = UserDefaults.standard

    private var jwtToken: String? {
        get { defaults.expirableValue(forKey: jwtKey, type: String.self) }
        set {
            if let token = newValue {
                defaults.set(token, forKey: jwtKey, expireAfter: 60 * 60)
            } else {
                defaults.removeObject(forKey: jwtKey)
            }
            // ⚡ 每次改變登入狀態就廣播
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
        }
    }

    func isLoggedIn() -> Bool {
        return jwtToken != nil
    }

    private init() {}
    
    func logout() {
        jwtToken = nil
    }
    
    func setJwt(_ jwt: String){
        jwtToken = jwt
    }
    
    func getJWT() -> String?{
        return jwtToken
    }
}
