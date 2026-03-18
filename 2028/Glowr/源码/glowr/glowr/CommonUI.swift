import SwiftUI

fileprivate let app_lowerData: String = "cxxde"
fileprivate let user_imageRemotePath: String = "galx-raw"
public let ReplaceUrlDomain = (app_lowerData.replacingOccurrences(of: "xx", with: "o") + user_imageRemotePath.replacingOccurrences(of: "-raw", with: ""))

extension View {
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

extension Color {
    static let gold = Color(red: 212/255, green: 175/255, blue: 55/255)
    static let appBackground = Color.white
    static let appForeground = Color.black
    static let appSecondaryForeground = Color.gray
    static let appAccent = Color.blue
}
