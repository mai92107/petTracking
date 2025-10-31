//
//  NetworkMonitor.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/31.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected = false {
        didSet {
            if oldValue != isConnected {
                print("🌐 網路狀態改變: \(isConnected ? "已連線" : "已斷線")")
                postNetworkStatusNotification()
            }
        }
    }
    
    private(set) var connectionType: NWInterface.InterfaceType?
    
    private init() {}
    
    // MARK: - Public Methods
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.updatePath(path)
        }

        monitor.start(queue: queue)
        print("🔍 開始監控網路狀態")
        
        // 🚀 立即讀取當前網路狀態
        updatePath(monitor.currentPath)
    }
    
    func stopMonitoring() {
        monitor.cancel()
        print("🔍 停止監控網路狀態")
    }
    
    // MARK: - Private Helpers
    private func updatePath(_ path: NWPath) {
        let wasConnected = isConnected
        isConnected = path.status == .satisfied
        
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("📶 使用 WiFi")
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("📱 使用行動網路")
        } else {
            connectionType = nil
        }
        
        if wasConnected && !isConnected {
            print("⚠️ 網路已斷線")
            handleNetworkLost()
        } else if !wasConnected && isConnected {
            print("✅ 網路已連線")
            handleNetworkRestored()
        }
    }

    private func postNetworkStatusNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("NetworkStatusChanged"),
                object: nil,
                userInfo: ["isConnected": self.isConnected]
            )
        }
    }
    
    private func handleNetworkLost() {
        // 網路斷線時的處理
        DispatchQueue.main.async {
            // 通知 MQTT 斷線
            MQTTManager.shared.handleNetworkLost()
        }
    }
    
    private func handleNetworkRestored() {
        // 網路恢復時的處理
        DispatchQueue.main.async {
            // 嘗試重新連線 MQTT
            MQTTManager.shared.handleNetworkRestored()
        }
    }
}
