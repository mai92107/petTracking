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
    
    case RECORDING = "device_recording"
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
    func publishLocation(latitude: Double, longitude: Double, jwt: String, on newRecord: String) {
        
//        guard let deviceId = AuthManager.shared.getDeviceId() else {
//            return
//        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        
        // 建立 JSON 資料
        let locationData: [String: Any] = [
            "lat": latitude,
            "lng": longitude,
            "deviceId": DeviceConfig.deviceId,
            "recordAt": formatter.string(from: Date()),
            "dataRef": newRecord,
        ]
        
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"

        // 發布到 topic
        publishData(action: Action.RECORDING.rawValue, data: locationData, clientId: MQTTConfig.clientID, jwt: AuthManager.shared.getJWT()!, ip: ip)
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
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"
        return await publishAndGetData(action: Action.REGISTER.rawValue,
                                          data: data,
                                          clientId: MQTTConfig.clientID,
                                          jwt: "",
                                          ip: ip)
    }
    
    struct LoginData: Codable {
        let token: String
        let identity: String
        let loginTime: String
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
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"
        return await publishAndGetData(action: Action.SYSTEM_STATUS.rawValue,
                                       data: [:],
                                       clientId: MQTTConfig.clientID,
                                       jwt: "",
                                       ip: ip)
    }
    
    struct DevStatusData: Codable{
        let lastSeen: String
        let online: Bool
    }
    
    func publishDevStatusData(deviceId: String) async -> MQTTResponse<CommonResponse<DevStatusData>>{
        let data: [String: String] = [
            "deviceId": deviceId,
        ]
        let ip: String = NetworkUtils.getIPAddress() ?? "0:0:0:0"
        return await publishAndGetData(action: Action.DEVICE_STATUS.rawValue,
                                       data: data,
                                       clientId: MQTTConfig.clientID,
                                       jwt: AuthManager.shared.getJWT()!,
                                       ip: ip)
    }
}
