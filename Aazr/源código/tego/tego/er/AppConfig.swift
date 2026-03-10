//
//  AppConfig.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

import KeychainSwift
import UIKit

/// 域名
let ReplaceUrlDomain = "codegalx"
/// 包ID
let PackageID = "2020"
/// Adjust
let AdjustKey = "3rhcdcv7zxc0"
let AdInstallToken = "y7hqge"

/// 网络版本号
let AppNetVersion = "1.9.1"
let H5WebDomain = "https://m.\(ReplaceUrlDomain).com"
let AppVersion =
    Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let AppBundle = Bundle.main.bundleIdentifier!
let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let AppBuildNumber =
    Bundle.main.infoDictionary!["CFBundleVersion"] as! String

class AppConfig: NSObject {
    class func p_k9f4() -> CGFloat {
        if #available(iOS 13.0, *) {
            if let statusBarManager = UIApplication.shared.windows.first?
                .windowScene?.statusBarManager
            {
                return statusBarManager.statusBarFrame.size.height
            }
        } else {
            return UIApplication.shared.statusBarFrame.size.height
        }
        return 20.0
    }

    class func p_l2a8() -> UIWindow {
        var window = UIApplication.shared.windows.first(where: {
            $0.isKeyWindow
        })
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for windowTemp in windows {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    window = windowTemp
                    break
                }
            }
        }
        return window!
    }

    class func p_m5b3() -> (UIViewController?) {
        var window = AppConfig.p_l2a8()
        if window.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for windowTemp in windows {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window.rootViewController
        return p_m5b3(vc)
    }

    class func p_m5b3(_ vc: UIViewController?)
        -> UIViewController?
    {
        if vc == nil {
            return nil
        }
        if let presentVC = vc?.presentedViewController {
            return p_m5b3(presentVC)
        } else if let tabVC = vc as? UITabBarController {
            if let selectVC = tabVC.selectedViewController {
                return p_m5b3(selectVC)
            }
            return nil
        } else if let naiVC = vc as? UINavigationController {
            return p_m5b3(naiVC.visibleViewController)
        } else {
            return vc
        }
    }
}

// MARK: - Device
extension UIDevice {
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") {
            identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    static var timeZone: String {
        let currentTimeZone = NSTimeZone.system
        return currentTimeZone.identifier
    }

    static var langCode: String {
        let language = Locale.preferredLanguages.first
        return language ?? ""
    }

    static var interfaceLang: String {
        let lang = UIDevice.getSystemLangCode()
        if ["en", "ar", "es", "pt"].contains(lang) {
            return lang
        }
        return "en"
    }

    static var countryCode: String {
        let locale = Locale.current
        let countryCode = locale.regionCode
        return countryCode ?? ""
    }

    static var systemUUID: String {
        let key = KeychainSwift()
        if let value = key.get(AdjustKey) {
            return value
        } else {
            let value = NSUUID().uuidString
            key.set(value, forKey: AdjustKey)
            return value
        }
    }

    static var getInstalledApps: String {
        var appsArr: [String] = []
        if UIDevice.canOpenApp("weixin") {
            appsArr.append("weixin")
        }
        if UIDevice.canOpenApp("wxwork") {
            appsArr.append("wxwork")
        }
        if UIDevice.canOpenApp("dingtalk") {
            appsArr.append("dingtalk")
        }
        if UIDevice.canOpenApp("lark") {
            appsArr.append("lark")
        }
        if appsArr.count > 0 {
            return appsArr.joined(separator: ",")
        }
        return ""
    }

    static func canOpenApp(_ scheme: String) -> Bool {
        let url = URL(string: "\(scheme)://")!
        if UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }

    @objc public class func getSystemLangCode() -> String {
        let language = NSLocale.preferredLanguages.first
        let array = language?.components(separatedBy: "-")
        return array?.first ?? "en"
    }
}
