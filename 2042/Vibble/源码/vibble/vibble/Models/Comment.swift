//
//  Comment.swift
//  vibble
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
struct Comment: Identifiable, Codable {
    var id = UUID()
    let user: String
    let text: String
    let colorHex: String // 存储颜色 Hex 字符串以便 Codable
    
    var color: Color {
        Color(hex: colorHex) // 使用 Theme.swift 中已有的全局定义
    }
    
    init(id: UUID = UUID(), user: String, text: String, color: Color) {
        self.id = id
        self.user = user
        self.text = text
        self.colorHex = color.toHex() ?? "#FF2D55"
    }
}

// 仅保留 Color 转 Hex 的方法，避免与 Theme.swift 冲突
@available(iOS 14.0, *)
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
