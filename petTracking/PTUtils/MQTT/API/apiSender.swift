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
    
    func publishLoginData(username: String, password: String){
        let data: [String: String] = [
            "userAccount": username,
            "password": password
        ]
        let ip: String = NetworkUtils.getIPAddress() ?? ""
        publishAndGetData(action: Action.LOGIN.rawValue,
                          data: data,
                          clientId: MQTTConfig.clientID,
                          jwt: "",
                          ip: ip)
    }
    
    func publishAndGetData(action: String, data: [String: String], clientId: String, jwt: String, ip: String){
        let topic = "req/\(action)/\(clientId)/\(jwt)/\(ip)"
        func printAll(_ message: String){
            print(message)
        }
        publishAndWaitResponse(data: data, publishTopic: topic, completion: printAll)
    }
}
