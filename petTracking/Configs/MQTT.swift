//
//  MQTT.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation
import CocoaMQTT

struct MQTTConfig {
    // MQTT Broker 設定
    static let host = "test.mosquitto.org"
    static let port: UInt16 = 1883
    
    // 認證資訊 (如果需要)
    static let username: String? = nil  // 有帳號就填入 "your_username"
    static let password: String? = nil  // 有密碼就填入 "your_password"
    
    // 連線設定
    static let keepAlive: UInt16 = 60
    static let autoReconnect = true
    
    // QoS 設定
    static let qos: CocoaMQTTQoS = .qos1
    
    // Client ID 前綴
    static let clientID = "iOS_PetTracker"
    
    // 裝置編號
    static let deviceId = "AA-000001"
    
    // 裝置唯一識別碼
    static let deviceUuid = "c55a5e3c-7c97-424f-9051-496fbd89cb3f"
}
