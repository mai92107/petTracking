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
    private let deviceKey = "member_deviceId"
    private let roleKey = "member_role"
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
//    
//    private var deviceId: String? {
//        get { defaults.expirableValue(forKey: deviceKey, type: String.self) }
//        set {
//            if let id = newValue {
//                defaults.set(id, forKey: deviceKey, expireAfter: 60 * 60)
//            } else {
//                defaults.removeObject(forKey: deviceKey)
//            }
//        }
//    }
    
    private var role: String? {
        get { defaults.expirableValue(forKey: roleKey, type: String.self) }
        set {
            if let id = newValue {
                defaults.set(id, forKey: roleKey, expireAfter: 60 * 60)
            } else {
                defaults.removeObject(forKey: roleKey)
            }
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
    
//    func setDeviceId(_ id: String){
//        return deviceId = id
//    }
//    
//    func getDeviceId() -> String?{
//        return deviceId
//    }
    
    func setRole(_ roleType: String){
        role = roleType
    }
    
    func isAdmin() -> Bool{
        return role == "ADMIN"
    }
}
