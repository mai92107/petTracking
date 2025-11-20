//
//  KeychainHelper.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/20.
//

import UIKit

class KeychainHelper {
    static let shared = KeychainHelper()
    
    func save(_ key: String, value: String) {
        if let data = value.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as CFDictionary
            
            SecItemDelete(query) // 先刪除舊的
            SecItemAdd(query, nil)
        }
    }
    
    func get(_ key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query, &dataTypeRef) == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}
