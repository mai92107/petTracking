//
//  LocationUtil.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/3.
//

import UIKit

class LocationUtil{
    static let shared = LocationUtil()
    
    private init() {}  // 🔥 防止外部建立實例

    private func toString(double: Double) -> String{
        return String(format: "%.7f", double)
    }
    private func toDouble(string: String) -> Double{
        guard let target = Double(string) else { return 0 }
        return target
    }
    
    func Get7NumberLocation(double: Double) -> Double{
        return toDouble(string: toString(double: double))
    }
    
}
