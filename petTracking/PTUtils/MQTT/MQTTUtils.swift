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

    func publish(data: String, to topic: String){
        guard let client = MQTTManager.shared.mqttClient, client.connState == .connected else {
            print("MQTT 未連線,無法發送資料")
            return
        }
        
        client.publish(topic, withString: data, qos: MQTTConfig.qos)
        
        print("📤 已發送, 主題: \(topic), 內容: \(data)")
    }
    
    func publishAndWaitResponse(
          data: [String: String],
          publishTopic: String,
          qos: CocoaMQTTQoS = .qos1,
          completion: @escaping (_ message: String) -> Void
      ) {
          guard let client = MQTTManager.shared.mqttClient, client.connState == .connected else {
              print("⚠️ MQTT 未連線，無法發送或訂閱")
              return
          }
          
          // 加入接收主題
          let subscribeTopic = UUID().uuidString
          
          var payload = data
          payload["subscribeTo"] = subscribeTopic
          
          // 1️⃣ 訂閱回覆主題
          client.subscribe(subscribeTopic, qos: qos)
          print("📡 訂閱主題: \(subscribeTopic)")

          // 2️⃣ 設定臨時 delegate 監聽回覆
          let responseDelegate = MQTTResponseDelegate(subscribeTopic: subscribeTopic, completion: completion)
          MQTTManager.shared.addTemporaryDelegate(responseDelegate)

          // 轉為json string
          if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
             let jsonString = String(data: jsonData, encoding: .utf8) {
              // 3️⃣ 發佈訊息
              client.publish(publishTopic, withString: jsonString, qos: qos)
              print("📤 發佈訊息到 \(publishTopic): \(jsonString)")
          }

      }
}

/// 用於單次等待回覆的 delegate（含 timeout）
class MQTTResponseDelegate: MQTTManagerDelegate {
    private let subscribeTopic: String
    private let completion: (_ message: String) -> Void
    private var timeoutTask: DispatchWorkItem?
    private var isCompleted = false

    init(
        subscribeTopic: String,
        timeout: TimeInterval = 10, // 預設 10 秒
        completion: @escaping (_ message: String) -> Void
    ) {
        self.subscribeTopic = subscribeTopic
        self.completion = completion

        // 啟動 timeout 計時
        timeoutTask = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isCompleted else { return }

            self.isCompleted = true

            // 取消訂閱與清理
            if let client = MQTTManager.shared.mqttClient {
                client.unsubscribe(self.subscribeTopic)
                print("🚫 已取消訂閱 (逾時): \(self.subscribeTopic)")
            }

            MQTTManager.shared.removeTemporaryDelegate(self)
        }

        // 在背景 queue 排程 timeout
        if let timeoutTask = timeoutTask {
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutTask)
        }
    }

    func mqttStatusChanged(isConnected: Bool) {
        // 可忽略
    }

    func mqttMsgGet(topic: String, message: String) {
        // 只處理指定主題
        guard topic == subscribeTopic, !isCompleted else { return }

        isCompleted = true
        timeoutTask?.cancel()

        print("✅ 已收到回覆: \(message) ")

        // 呼叫回呼
        completion(message)

        // 收到後取消訂閱
        if let client = MQTTManager.shared.mqttClient {
            client.unsubscribe(subscribeTopic)
        }

        MQTTManager.shared.removeTemporaryDelegate(self)
    }
}
