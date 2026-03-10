//
//  AppWebViewHandleEvent.swift
//  OverseaH5
//
//  Created by young on 2025/9/23.
//

import CoreTelephony
import FirebaseMessaging
import HandyJSON
import StoreKit
import UIKit

private let getDeviceID     = "getDeviceID"
private let getFirebaseID   = "getFirebaseID"
private let getAreaISO      = "getAreaISO"
private let getProxyStatus  = "getProxyStatus"
private let getMicStatus    = "getMicStatus"
private let getPhotoStatus  = "getPhotoStatus"
private let getCameraStatus = "getCameraStatus"
private let reportAdjust    = "reportAdjust"
private let requestLocalPush = "requestLocalPush"
private let getLangCode      = "getLangCode"
private let getTimeZone      = "getTimeZone"
private let getInstalledApps = "getInstalledApps"
private let getSystemUUID    = "getSystemUUID"
private let getCountryCode   = "getCountryCode"
private let inAppRating      = "inAppRating"
private let apPay            = "apPay"
private let subscribe        = "subscribe"
private let openSystemBrowser = "openSystemBrowser"
private let closeWebview     = "closeWebview"
private let openNewWebview   = "openNewWebview"
private let reloadWebview    = "reloadWebview"
private let openSettings = "openSettings"
private let getNotificationStatus = "getNotificationStatus"
private let setScheduledLocalPush = "setScheduledLocalPush"

struct JSMessageModel: HandyJSON {
    var typeName = ""
    var token: String?
    var totalCount: Double?
    var showText: String?
    var data: UserInfoModel?
    var goodsId: String?
    var source: Int?
    var type: Int?
    var url: String?
    var fullscreen: Int?
    var transparency: Int?
    var time: [Int]?
    var msg: [String]?
}

struct UserInfoModel: HandyJSON {
    var headPic: String?
    var nickname: String?
    var uid: String?
}

extension AppWebViewController {
    func handleH5Message(schemeDic: [String: Any], callBack: @escaping (_ backDic: [String: Any]) -> Void) {
        if let model = JSMessageModel.deserialize(from: schemeDic) {
            switch model.typeName {
            case getDeviceID:
                let adidStr = AppAdjustManager.p_g4b9()
                callBack(["typeName": model.typeName, "deviceID": adidStr])

            case getFirebaseID:
                AppWebViewController.p_bs0c9 { str in
                    callBack(["typeName": model.typeName, "fireBaseID": str])
                }
                
            case getAreaISO:
                let arr = AppWebViewController.p_bt3d2()
                callBack(["typeName": model.typeName, "areaISO": arr.joined(separator: ",")])
                
            case getProxyStatus:
                let status = AppWebViewController.p_bu6e5()
                callBack(["typeName": model.typeName, "isProxy": status])
              
            case getLangCode:
                callBack(["typeName": model.typeName, "langCode": UIDevice.langCode])
                
            case getTimeZone:
                callBack(["typeName": model.typeName, "timeZone": UIDevice.timeZone])
                
            case getInstalledApps:
                callBack(["typeName": model.typeName, "installedApps": UIDevice.getInstalledApps])
                
            case getSystemUUID:
                callBack(["typeName": model.typeName, "systemUUID": UIDevice.systemUUID])
                
            case getCountryCode:
                callBack(["typeName": model.typeName, "countryCode": UIDevice.countryCode])
                
            case inAppRating:
                callBack(["typeName": model.typeName])
                AppWebViewController.p_bx5b4()

            case apPay:
                if let goodsId = model.goodsId, let source = model.source {
                    self.p_by8c7(productId: goodsId, source: source, payType: .Pay) { success in
                        callBack(["typeName": model.typeName, "status": success])
                    }
                }

            case subscribe:
                if let goodsId = model.goodsId {
                    self.p_by8c7(productId: goodsId, payType: .Subscribe) { success in
                        callBack(["typeName": model.typeName, "status": success])
                    }
                }
                
            case openSystemBrowser:
                callBack(["typeName": model.typeName])
                if let urlStr = model.url, let openURL = URL(string: urlStr) {
                    UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
                }
                
            case closeWebview:
                callBack(["typeName": model.typeName])
                self.closeWeb()
                
            case openNewWebview:
                callBack(["typeName": model.typeName])
                if let urlStr = model.url,
                    let transparency = model.transparency,
                    let fullscreen = model.fullscreen {
                    AppWebViewController.p_bq4a3(urlStr, transparency, fullscreen)
                }
                
            case reloadWebview:
                callBack(["typeName": model.typeName])
                self.reloadWebView()
            
            case openSettings:
                callBack(["typeName": model.typeName])
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
                }
                
            case setScheduledLocalPush:
                callBack(["typeName": model.typeName])
                LocalPushScheduler.shared.p_v5e3(times: model.time ?? [], contents: model.msg ?? [])
                
            case getNotificationStatus:
                AppPermissionTool.shared.p_q0f5 { auth, isFirst in
                    callBack(["typeName": model.typeName, "isAuth": auth, "isFirst": isFirst])
                }
            
            case getMicStatus:
                AppPermissionTool.shared.p_n1c6 { auth, isFirst in
                    callBack(["typeName": model.typeName, "isAuth": auth, "isFirst": isFirst])
                }
                
            case getPhotoStatus:
                AppPermissionTool.shared.p_o4d9 { auth, isFirst in
                    callBack(["typeName": model.typeName, "isAuth": auth, "isFirst": isFirst])
                }
                
            case getCameraStatus:
                AppPermissionTool.shared.p_p7e2 { auth, isFirst in
                    callBack(["typeName": model.typeName, "isAuth": auth, "isFirst": isFirst])
                }
                
            case reportAdjust:
                if let token = model.token {
                    if let count = model.totalCount {
                        AppAdjustManager.p_i3d7(token: token, count: count)
                    } else {
                        AppAdjustManager.p_j6e1(token: token)
                    }
                }
                callBack(["typeName": model.typeName])

            case requestLocalPush:
                callBack(["typeName": model.typeName])
                AppWebViewController.p_br7b6(model)

            default: break
            }
        }
    }
}

// MARK: - Event
extension AppWebViewController {
    class func p_bq4a3(_ urlStr: String, _ transparency: Int = 0, _ fullscreen: Int = 1) {
        let vc = AppWebViewController()
        vc.urlString = urlStr
        vc.clearBgColor = (transparency == 1)
        vc.fullscreen = (fullscreen == 1)
        vc.modalPresentationStyle = .fullScreen
        AppConfig.p_m5b3()?.present(vc, animated: true)
    }
    
    class func p_br7b6(_ model: JSMessageModel) {
        guard UIApplication.shared.applicationState != .active else { return }
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            switch setting.authorizationStatus {
            case .notDetermined, .denied, .ephemeral:
                print("本地推送通知 -- 用户未授权\(setting.authorizationStatus)")
            case .provisional, .authorized:
                if let dataModel = model.data {
                    let content = UNMutableNotificationContent()
                    content.title = dataModel.nickname ?? ""
                    content.body = model.showText ?? ""
                    let identifier = dataModel.uid ?? "\(AppName)__LocalPush"
                    content.userInfo = ["identifier": identifier]
                    content.sound = UNNotificationSound.default
                    let time = Date(timeIntervalSinceNow: 1).timeIntervalSinceNow
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { _ in }
                }
            @unknown default:
                print("本地推送通知 -- 用户未授权\(setting.authorizationStatus)")
                break
            }
        }
    }
    
    class func p_bs0c9(tokenBlock: @escaping (_ str: String) -> Void) {
        Messaging.messaging().token { token, _ in
            if let token = token {
                tokenBlock(token)
            } else {
                tokenBlock("")
            }
        }
    }

    class func p_bt3d2() -> [String] {
        var tempArr: [String] = []
        let info = CTTelephonyNetworkInfo()
        if let carrierDic = info.serviceSubscriberCellularProviders {
            if !carrierDic.isEmpty {
                for carrier in carrierDic.values {
                    if let iso = carrier.isoCountryCode, !iso.isEmpty {
                        tempArr.append(iso)
                    }
                }
            }
        }
        return tempArr
    }

    class func p_bu6e5() -> Bool {
        if AppWebViewController.p_bv9f8() || AppWebViewController.p_bw2a1() {
            return true
        }
        return false
    }
    
    class func p_bv9f8() -> Bool {
        guard let proxy = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() else { return false }
        guard let dict = proxy as? [String: Any] else { return false }
        if let httpProxy = dict["HTTPProxy"] as? String, !httpProxy.isEmpty { return true }
        if let httpsProxy = dict["HTTPSProxy"] as? String, !httpsProxy.isEmpty { return true }
        if let socksProxy = dict["SOCKSProxy"] as? String, !socksProxy.isEmpty { return true }
        return false
    }
    
    class func p_bw2a1() -> Bool {
        guard let proxy = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() else { return false }
        guard let dict = proxy as? [String: Any] else { return false }
        guard let scopedDic = dict["__SCOPED__"] as? [String: Any] else { return false }
        for keyStr in scopedDic.keys {
            if keyStr.contains("tap") || keyStr.contains("tun") || keyStr.contains("ipsec") || keyStr.contains("ppp") {
                return true
            }
        }
        return false
    }
    
    class func p_bx5b4() {
        if #available(iOS 14.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    func p_by8c7(productId: String, source: Int = -1, payType: ApplePayType, completion: ((Bool) -> Void)? = nil) {
        ProgressHUD.show()
        var index = 0
        if source != -1 { index = source }
        AppleIAPManager.shared.p_ad9a7(productId: productId, payType: payType, source: index) { status, _, _ in
            ProgressHUD.dismiss()
            DispatchQueue.main.async {
                var isSuccess = false
                switch status {
                case .verityFail:
                    ProgressHUD.toast("Retry After or Go to \"Feedback\" to contact us")
                case .veritySucceed, .renewSucceed:
                    isSuccess = true
                    self.p_bz1e4()
                default:
                    print("apple支付充值失败：\(status.rawValue)")
                    break
                }
                completion?(isSuccess)
            }
        }
    }
}
