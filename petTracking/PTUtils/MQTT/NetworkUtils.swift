//
//  NetworkUtils.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import Foundation
import Network

class NetworkUtils {
    
    // 取得當前 IP 位址
    static func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // 取得介面名稱
                    let name = String(cString: interface.ifa_name)
                    
                    // 只取 WiFi (en0) 或 Cellular (pdp_ip0)
                    if name == "en0" || name == "pdp_ip0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        
                        if getnameinfo(interface.ifa_addr,
                                     socklen_t(interface.ifa_addr.pointee.sa_len),
                                     &hostname,
                                     socklen_t(hostname.count),
                                     nil,
                                     socklen_t(0),
                                     NI_NUMERICHOST) == 0 {
                            address = String(cString: hostname)
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    // 取得所有網路介面的 IP
    static func getAllIPAddresses() -> [String: String] {
        var addresses: [String: String] = [:]
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    if getnameinfo(interface.ifa_addr,
                                 socklen_t(interface.ifa_addr.pointee.sa_len),
                                 &hostname,
                                 socklen_t(hostname.count),
                                 nil,
                                 socklen_t(0),
                                 NI_NUMERICHOST) == 0 {
                        addresses[name] = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
    // 取得 WiFi IP
    static func getWiFiAddress() -> String? {
        return getAllIPAddresses()["en0"]
    }
    
    // 取得行動網路 IP
    static func getCellularAddress() -> String? {
        return getAllIPAddresses()["pdp_ip0"]
    }
}
