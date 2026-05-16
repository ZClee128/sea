//
//  Extensions.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
extension View {
    /// 全局点击收起键盘的方法
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    /// 自定义占位符扩展，兼容 iOS 14
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

@available(iOS 14.0, *)
extension UIApplication {
    /// 强制收起键盘
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
