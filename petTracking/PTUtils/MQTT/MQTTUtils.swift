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
    
    // MARK: 無需回覆，但須監聽錯誤
    func publishAndGetErrorData(
        action: String,
        data: [String: Any],
        clientId: String,
        jwt: String,
        ip: String
    ) async -> MQTTResponse<CommonResponse<String>> {
        
        let topic = "req/\(action)/\(clientId)/\(jwt)/\(ip)"
        
        return await withCheckedContinuation { continuation in
            var finished = false
            
            publishAndNoResponse(data: data, to: topic) { reply in
                guard !finished else { return }
                finished = true
                continuation.resume(returning: reply)
            }
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(MQTTConfig.timeout * 1_000_000_000))
                guard !finished else { return }
                finished = true
                continuation.resume(returning: .timeout)
            }
        }
    }
    
    // MARK: 需回覆
    func publishAndGetData<T: Decodable>(
        action: String,
        data: [String: Any],
        clientId: String,
        jwt: String,
        ip: String
    ) async -> MQTTResponse<CommonResponse<T>> {
        
        let topic = "req/\(action)/\(clientId)/\(jwt)/\(ip)"
        
        return await withCheckedContinuation { continuation in
            var finished = false
            
            publishAndWaitResponse(data: data, publishTopic: topic) { reply in
                guard !finished else { return }
                finished = true
                continuation.resume(returning: reply)
            }
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(MQTTConfig.timeout * 1_000_000_000))
                guard !finished else { return }
                finished = true
                continuation.resume(returning: .timeout)
            }
        }
    }
    
    func publishAndNoResponse<T: Decodable>(
        data: [String:Any],
        to topic: String,
        qos: CocoaMQTTQoS = .qos1,
        completion: @escaping (MQTTResponse<T>) -> Void
    ){
        guard let client = MQTTManager.shared.mqttClient, client.connState == .connected else {
            print("⚠️ MQTT 未連線,無法發送資料")
            return
        }
        
        // 1️⃣ 訂閱回覆主題, 增加錯誤回覆
        let errTopic = "errReq/\(MQTTConfig.clientID)"
        client.subscribe([(errTopic, qos: qos)])
        print("📡 訂閱主題: \(errTopic)")
            
        // 2️⃣ 設定臨時 delegate 監聽回覆
        let responseDelegate = MQTTResponseDelegate(
                subscribeTopic: nil,
                errTopic: errTopic
        ) { result in

            switch result {
            case .failure(let errorMsg):
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: Data(errorMsg.utf8))
                    completion(.failure(decoded))
                } catch {
                    print("⚠️ 錯誤訊息不是 CommonResponse 格式: \(errorMsg)")
                }
            case .rawResponse(let jsonString):
                completion(.rawResponse(jsonString))
            default:
                break
            }
        }
        
        MQTTManager.shared.addTemporaryDelegate(responseDelegate)

        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            // 3️⃣ 發佈訊息
            client.publish(topic, withString: jsonString, qos: qos)
            print("📤 發佈訊息到 \(topic): \(jsonString)")
        }
    }
    
    func publishAndWaitResponse<T: Decodable>(
          data: [String: Any],
          publishTopic: String,
          qos: CocoaMQTTQoS = .qos1,
          completion: @escaping (MQTTResponse<T>) -> Void
      ) {
          guard let client = MQTTManager.shared.mqttClient, client.connState == .connected else {
              print("⚠️ MQTT 未連線，無法發送或訂閱")
              return
          }
          
          // 加入接收主題
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
                  errTopic: errTopic
          ) { result in

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
    
    private let subscribeTopic: String?
    private let errTopic: String
    private let completion: (MQTTResponse<String>) -> Void
    
    private var finished = false
    private var timeoutWork: DispatchWorkItem?

    init(
        subscribeTopic: String?,
        errTopic: String,
        timeout: TimeInterval = MQTTConfig.timeout,
        completion: @escaping (MQTTResponse<String>) -> Void
    ) {
        self.subscribeTopic = subscribeTopic
        self.errTopic = errTopic
        self.completion = completion

        // 啟動 timeout 計時
        timeoutWork = DispatchWorkItem { [weak self] in
            guard let self = self, !self.finished else { return }
            self.finished = true
            self.completion(.timeout)
            self.cleanup()
        }

        // 在背景 queue 排程 timeout
        if let timeoutTask = timeoutWork {
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutTask)
        }
    }

    func mqttStatusChanged(isConnected: Bool) {
        // 可忽略
    }

    func mqttMsgGet(topic: String, message: String) {
        // 只處理指定主題
        guard topic == subscribeTopic || topic == errTopic else { return }
        guard !finished else { return }

        finished = true
        timeoutWork?.cancel()

        print("📩 收到 MQTT: [\(topic)] \(message)")

        if topic == subscribeTopic{
            completion(.success(message))
        } else if topic == errTopic {
            completion(.failure(message))
        }
        completion(.rawResponse(message))
        cleanup()
    }

    private func cleanup() {
        if let client = MQTTManager.shared.mqttClient {
            if let s = subscribeTopic { client.unsubscribe(s) }
            client.unsubscribe(errTopic)
        }
        MQTTManager.shared.removeTemporaryDelegate(self)
    }
}

