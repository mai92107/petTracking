//
//  MQTTUtils.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation
import CocoaMQTT

class MQTTUtils{
    
    static let shared = MQTTUtils()
    
    private init() {}  // 🔥 防止外部建立實例
    
    // 發布位置資料
    func publishLocation(latitude: Double, longitude: Double, jwt: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        
        // 建立 JSON 資料
        let locationData: [String: Any] = [
            "lat": latitude,
            "lng": longitude,
            "deviceId": MQTTConfig.deviceId,
            "subscribeTo":MQTTConfig.deviceUuid,
            "recordAt": formatter.string(from: Date())
        ]
        
        let ip: String = NetworkUtils.getIPAddress() ?? ""
        
        // 轉換為 JSON 字串
        if let jsonData = try? JSONSerialization.data(withJSONObject: locationData, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            // 發布到 topic
            let topic = "req/device_recording/\(jwt)/\(MQTTConfig.clientID)/\(ip)"
            publish(data: jsonString, to: topic)
        }
    }

    func publish(data: String, to topic: String){
        guard let client = MQTTManager.shared.mqttClient, client.connState == .connected else {
            print("MQTT 未連線,無法發送資料")
            return
        }
        
        client.publish(topic, withString: data, qos: .qos1)
        
        print("📤 已發送, 主題: \(topic), 內容: \(data)")
    }
}

