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
    private let clientID = MQTTConfig.clientID
    
    // MARK: - Connection State
     private(set) var isConnect = false {
         didSet {
             // 當連線狀態改變時發送通知
             if oldValue != isConnect {
                 postConnectionStatusNotification()
             }
         }
     }
    
    private init() {}
    
    // 連接 MQTT
    func connect() {
        // 若無網路則不嘗試連線
        if !NetworkMonitor.shared.isConnected{
            print("⚠️ 網路無連線，MQTT不嘗試連線")
            return
        }
        // 如果已經有 client 且已連線,不重複連線
        if let client = mqttClient, client.connState == .connected {
            print("⚠️ MQTT 已經連線")
            return
        }
        
        mqttClient = CocoaMQTT(clientID: clientID, host: MQTTConfig.host, port: MQTTConfig.port)
        
        mqttClient?.username = MQTTConfig.username
        mqttClient?.password = MQTTConfig.password
        
        mqttClient?.keepAlive = MQTTConfig.keepAlive
        mqttClient?.delegate = self
        mqttClient?.autoReconnect = true
        
        // 嘗試連線
        let success = mqttClient?.connect() ?? false
        print(success ? "🔄 正在連接 MQTT Broker..." : "❌ MQTT 連線啟動失敗")
    }
    
    // 斷線
    func disconnect() {
        mqttClient?.disconnect()
        print("🔌 MQTT 斷線中...")
    }
    
    // MARK: - Network Change Handling
    func handleNetworkLost() {
        print("⚠️ 網路斷線,標記 MQTT 為斷線")
        isConnect = false
    }
    
    func handleNetworkRestored() {
        print("✅ 網路恢復,嘗試重新連線 MQTT")
        
        // 如果 MQTT 處於斷線狀態,自動重連
        if !isConnect {
            // 稍微延遲一下,確保網路穩定
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.connect()
            }
        }
    }
    
    // MARK: - Private Helpers
    private func postConnectionStatusNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name("MQTTStatusChanged"),
            object: nil,
            userInfo: ["isConnected": isConnect]
        )
    }
}

// MARK: - CocoaMQTTDelegate
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        isConnect = (ack == .accept)
        print(isConnect ? "✅ MQTT 連線成功" : "❌ MQTT 連線失敗: \(ack)")
        
        // 🔥 發送通知
        NotificationCenter.default.post(
            name: NSNotification.Name("MQTTStatusChanged"),
            object: nil,
            userInfo: ["isConnected": isConnect]
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
