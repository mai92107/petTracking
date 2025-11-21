//
//  MQTTManager.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation
import CocoaMQTT

protocol MQTTManagerDelegate: AnyObject{
    func mqttStatusChanged(isConnected: Bool)
    func mqttMsgGet(topic: String, message: String)
}

class MQTTManager {
    static let shared = MQTTManager()
    
    public var mqttClient: CocoaMQTT?

    weak var delegate: MQTTManagerDelegate?
    
    private var temporaryDelegates = [MQTTManagerDelegate]()

    private let clientID = MQTTConfig.clientID
    
    public var isConnect = false
    
    private init() {}
    
    func addTemporaryDelegate(_ delegate: MQTTManagerDelegate) {
            temporaryDelegates.append(delegate)
    }

    func removeTemporaryDelegate(_ delegate: MQTTManagerDelegate) {
        temporaryDelegates.removeAll { $0 === delegate }
    }
    
    // 連接 MQTT
    func startConnect() {

        // 如果已經有 client 且已經連線或連線中,不重複連線
        if let client = mqttClient, client.connState == .connected || client.connState == .connecting {
            print("⚠️ MQTT 已經連線或連線中")
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
}

// MARK: - CocoaMQTTDelegate
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept{
            isConnect = true
        }
        print(isConnect ? "✅ MQTT 連線成功" : "❌ MQTT 連線失敗: \(ack)")
        delegate?.mqttStatusChanged(isConnected: isConnect)
        print("✓ 系統已連線")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📨 訊息已發布")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("✓ 訊息確認送達")
    }
    
    // CocoaMQTT 收到訊息
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let payload = message.string else { return }

        // 多個 工人 delegate
        for tempDelegate in temporaryDelegates {
            tempDelegate.mqttMsgGet(topic: message.topic, message: payload)
        }
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
        isConnect = false
        delegate?.mqttStatusChanged(isConnected: isConnect)
        print("系統連線中斷, 原因是 \(err!)")
    }
}
