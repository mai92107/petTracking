//
//  UIColor.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/10/30.
//

import UIKit

extension UIColor{
    
    static let ptPrimary = UIColor(hex: "16425B")
    static let ptSecondary = UIColor(hex: "2F6690")
    static let ptTertiary = UIColor(hex: "3A7CA5")
    static let ptQuaternary = UIColor(hex: "81C3D7")
    static let ptQuinary = UIColor(hex: "D9DCD6")
    
    static let backgroundColor = UIColor(hex: "#EDEAE6")
    static let bgColor = UIColor(hex: "#EDEAE6")
    static let btColor = UIColor(hex: "#C4B7A6")
    static let lColor = UIColor(hex: "#3A3A3A")
    static let iconColor = UIColor(hex: "#3A7CA5")
    static let globeColor = UIColor(hex: "#BFB9A8")
    
    // Hex 色碼初始化方法
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

// 顏色輪播
extension UIColor {
    convenience init(hexString: String) {
        var hexFormatted = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
