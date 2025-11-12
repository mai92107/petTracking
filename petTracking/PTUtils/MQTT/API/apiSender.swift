//
//  apiSender.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/10.
//

import Foundation

enum Action: String {
    case LOGIN = "account_login"
    case REGISTER = "account_register"
    
    case HELLO = "home_hello"
    
    case SYSTEM_STATUS = "system_status"
    case ADD_DEVICE = "member_addDevice"
    case DEVICE_STATUS = "device_status"
}

struct CommonResponse<T: Codable>: Decodable {
    let code: Int
    let message: String
    let data: T
    let requestedTime: String?
    let respondedTime: String?
}
struct EmptyResponse: Codable {}

extension MQTTUtils{
    
    // 發布位置資料
    func publishLocation(latitude: Double, longitude: Double, jwt: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        
        // 建立 JSON 資料
        let locationData: [String: Any] = [
            "lat": latitude,
            "lng": longitude,
            "deviceId": DeviceConfig.deviceId,
            "subscribeTo":DeviceConfig.deviceUuid,
            "recordAt": formatter.string(from: Date())
        ]
        
        let ip: String = NetworkUtils.getIPAddress() ?? ""
        
        // 轉換為 JSON 字串
        if let jsonData = try? JSONSerialization.data(withJSONObject: locationData, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            // 發布到 topic
            let topic = "req/device_recording/\(MQTTConfig.clientID)/\(jwt)/\(ip)"
            publish(data: jsonString, to: topic)
        }
    }
    
    struct RegisterData: Codable {
        let token: String
        let identity: String?
        let loginTime: String?
    }
    
    func publishRegisterData(username: String, email: String, password: String, firstname: String, lastname: String, nickname: String) async -> MQTTResponse<CommonResponse<RegisterData>>{
        let data: [String: String] = [
            "username": username,
            "password": password,
            "email": email,
            "lastName": lastname,
            "firstName": firstname,
            "nickName": nickname,
        ]
        let ip: String = NetworkUtils.getIPAddress() ?? ""
        return await publishAndGetData(action: Action.REGISTER.rawValue,
                                          data: data,
                                          clientId: MQTTConfig.clientID,
                                          jwt: "",
                                          ip: ip)
    }
    
    struct LoginData: Codable {
        let token: String
        let identity: String?
        let loginTime: String?
    }
    
    func publishLoginData(username: String, password: String) async -> MQTTResponse<CommonResponse<LoginData>>{
        let data: [String: String] = [
            "userAccount": username,
            "password": password
        ]
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"
        return await publishAndGetData(action: Action.LOGIN.rawValue,
                                       data: data,
                                       clientId: MQTTConfig.clientID,
                                       jwt: "",
                                       ip: ip)
    }
    
    struct SysStatusData: Codable{
        let message: String
        let mqtt_status: String
    }
    
    func publishSysStatusData() async -> MQTTResponse<CommonResponse<SysStatusData>>{
        let data: [String: String] = [
            "deviceId": DeviceConfig.deviceId,
        ]
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"
        return await publishAndGetData(action: Action.SYSTEM_STATUS.rawValue,
                                       data: data,
                                       clientId: MQTTConfig.clientID,
                                       jwt: "",
                                       ip: ip)
    }
    
    struct DevStatusData: Codable{
        let lastSeen: String
        let online: String
    }
    
    func publishDevStatusData() async -> MQTTResponse<CommonResponse<DevStatusData>>{
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"
        return await publishAndGetData(action: Action.DEVICE_STATUS.rawValue,
                                       data: [:],
                                       clientId: MQTTConfig.clientID,
                                       jwt: AuthManager.shared.getJWT()!,
                                       ip: ip)
    }
    
    func publishAndGetData<T: Decodable>(
        action: String,
        data: [String: String],
        clientId: String,
        jwt: String,
        ip: String
    ) async -> MQTTResponse<CommonResponse<T>> {
        
        let topic = "req/\(action)/\(clientId)/\(jwt)/\(ip)"
        
        return await withCheckedContinuation { continuation in
            var isCompleted = false
            
            publishAndWaitResponse(data: data, publishTopic: topic) { reply in
                guard !isCompleted else { return }
                isCompleted = true
                continuation.resume(returning: reply)
            }
            
            // 超時處理
            Task {
                try? await Task.sleep(nanoseconds: UInt64(MQTTConfig.timeout * 1_000_000_000))
                guard !isCompleted else { return }
                isCompleted = true
                continuation.resume(returning: .timeout)
            }
        }
    }
}
