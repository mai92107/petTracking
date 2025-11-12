//
//  UserDefault.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/12.
//

import Foundation

extension UserDefaults {
    
    /// 儲存帶過期時間的資料
    func set<T: Codable>(_ value: T, forKey key: String, expireAfter seconds: TimeInterval) {
        let expiryDate = Date().addingTimeInterval(seconds)
        let wrapper = Expirable(value: value, expiry: expiryDate)
        if let data = try? JSONEncoder().encode(wrapper) {
            self.set(data, forKey: key)
        }
    }

    /// 讀取資料（自動檢查是否過期）
    func expirableValue<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = self.data(forKey: key),
              let wrapper = try? JSONDecoder().decode(Expirable<T>.self, from: data)
        else { return nil }

        // 檢查是否過期
        if wrapper.expiry < Date() {
            self.removeObject(forKey: key)
            print("⚠️ \(key) 已過期，自動移除")
            return nil
        }
        return wrapper.value
    }

    private struct Expirable<T: Codable>: Codable {
        let value: T
        let expiry: Date
    }
}
