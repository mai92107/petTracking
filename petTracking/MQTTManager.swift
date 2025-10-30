//
//  MQTTManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation
import CocoaMQTT

class MQTTManager {
    static let shared = MQTTManager()
    
    public var mqttClient: CocoaMQTT?
    private let clientID = "iOS_PetTracker_\(ProcessInfo().globallyUniqueString)"
    
    private init() {}
    
    // 連接 MQTT
    func connect() {
        mqttClient = CocoaMQTT(clientID: clientID, host: MQTTConfig.host, port: MQTTConfig.port)
        
        mqttClient?.username = MQTTConfig.username
        mqttClient?.password = MQTTConfig.password
        
        mqttClient?.keepAlive = MQTTConfig.keepAlive
        mqttClient?.delegate = self
        mqttClient?.autoReconnect = true
        
        // 連線
        _ = mqttClient?.connect()
        
        print("正在連接 MQTT Broker...")
    }
    
    // 斷線
    func disconnect() {
        mqttClient?.disconnect()
        print("MQTT 已斷線")
    }
}

// MARK: - CocoaMQTTDelegate
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        let isConnected = (ack == .accept)
        print(isConnected ? "✅ MQTT 連線成功" : "❌ MQTT 連線失敗: \(ack)")
        
        // 🔥 發送通知
        NotificationCenter.default.post(
            name: NSNotification.Name("MQTTStatusChanged"),
            object: nil,
            userInfo: ["isConnected": isConnected]
        )
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📨 訊息已發布: \(message.topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("✓ 訊息確認送達")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        // 接收訊息
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("訂閱主題成功")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("取消訂閱")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Ping
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // Pong
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        if let error = err {
            print("❌ MQTT 斷線: \(error.localizedDescription)")
        } else {
            print("⚠️ MQTT 已斷線")
        }
    }
}
