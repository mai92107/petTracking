//
//  MQTTUtils.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation
import CocoaMQTT


enum MQTTResponse<T> {
    case success(T)             // 正常回覆
    case failure(T)             // 後端錯誤訊息
    case timeout                // 逾時
    case rawResponse(String)
}

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
    
    func publishAndWaitResponse<T: Decodable>(
          data: [String: String],
          publishTopic: String,
          qos: CocoaMQTTQoS = .qos1,
          completion: @escaping (MQTTResponse<T>) -> Void
      ) {
          guard let client = MQTTManager.shared.mqttClient, client.connState == .connected else {
              print("⚠️ MQTT 未連線，無法發送或訂閱")
              return
          }
          
          // 加入接收主題 及 錯誤訊息
          let subscribeTopic = UUID().uuidString
          
          var payload = data
          payload["subscribeTo"] = subscribeTopic
          
          // 1️⃣ 訂閱回覆主題, 增加錯誤回覆
          let errTopic = "errReq/\(MQTTConfig.clientID)"
          client.subscribe([(subscribeTopic, qos: qos),(errTopic, qos: qos)])
          print("📡 訂閱主題: \(subscribeTopic),\(errTopic)")

          // 2️⃣ 設定臨時 delegate 監聽回覆
          let responseDelegate = MQTTResponseDelegate(
                  subscribeTopic: subscribeTopic,
                  errTopic: errTopic) { result in
              // 收到 String 後，再解析成 T
              switch result {
              case .success(let jsonString):
                  do {
                      let decoded = try JSONDecoder().decode(T.self, from: Data(jsonString.utf8))
                      completion(.success(decoded))
                  } catch {
                      print("⚠️ 錯誤訊息不是 CommonResponse 格式: \(jsonString)")
                  }

              case .failure(let errorMsg):
                  do {
                      let decoded = try JSONDecoder().decode(T.self, from: Data(errorMsg.utf8))
                      completion(.failure(decoded))
                  } catch {
                      print("⚠️ 錯誤訊息不是 CommonResponse 格式: \(errorMsg)")
                  }

              case .timeout:
                  completion(.timeout)
              case .rawResponse(let jsonString):
                  completion(.rawResponse(jsonString))
              }
          }
          
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
    private let errTopic: String
    private let completion: (MQTTResponse<String>) -> Void
    private var timeoutTask: DispatchWorkItem?
    private var isCompleted = false

    init(
        subscribeTopic: String,
        errTopic: String,
        timeout: TimeInterval = MQTTConfig.timeout,
        completion: @escaping (MQTTResponse<String>) -> Void
    ) {
        self.subscribeTopic = subscribeTopic
        self.errTopic = errTopic
        self.completion = completion

        // 啟動 timeout 計時
        timeoutTask = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isCompleted else { return }

            self.isCompleted = true

            // 取消訂閱與清理
            if let client = MQTTManager.shared.mqttClient {
                client.unsubscribe(self.subscribeTopic)
                client.unsubscribe(self.errTopic)
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
        guard topic == subscribeTopic || topic == errTopic, !isCompleted else { return }

        isCompleted = true
        timeoutTask?.cancel()

        print("✅ 已收到回覆: \(message) ")

        if topic == subscribeTopic{
            // 呼叫回呼
            completion(.success(message))
        } else {
            completion(.failure(message))
        }
        completion(.rawResponse(message))
        cleanup()
    }

    private func cleanup() {
        if let client = MQTTManager.shared.mqttClient {
            client.unsubscribe([subscribeTopic, errTopic])
        }
        MQTTManager.shared.removeTemporaryDelegate(self)
    }
}

