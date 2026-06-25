//
//  AppAdjustManager.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

import Adjust
import CryptoKit


class AppAdjustManager: NSObject {
    static let shared = AppAdjustManager()
    
    /// 初始化Adjust
    func initAdjust() {
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(appToken: AdjustKey, environment: environment)
        adjustConfig?.logLevel = ADJLogLevelWarn
        adjustConfig?.delegate = self
        Adjust.appDidLaunch(adjustConfig)
        AppAdjustManager.addOnceEvent(token: AdInstallToken)
    }
}

// MARK: - Event
extension AppAdjustManager: AdjustDelegate {
    /// 获取设备id
    class func getAdjustAdid() -> String {
        let adid = Adjust.adid() ?? ""
        return adid
    }
    
    /// 添加去重事件【只记录一次】
    /// - Parameter key: 事件名
    class func addOnceEvent(token: String) {
        let event = ADJEvent(eventToken: token)
        event?.setTransactionId(token)
        Adjust.trackEvent(event)
    }

    /// 添加 内购/订阅 埋点事件
    /// - Parameters:
    ///   - token: Adjust event token
    ///   - count: 价格（USD）
    ///   - uid: 用户ID
    ///   - orderId: 订单ID
    class func addPurchasedEvent(token: String, count: Double, uid: String = "", orderId: String = "") {
        let event = ADJEvent(eventToken: token)
        event?.setRevenue(count, currency: "USD")
        if !uid.isEmpty {
            event?.addCallbackParameter("uid", value: uid)
        }
        if !orderId.isEmpty {
            event?.addCallbackParameter("order_id", value: orderId)
        }
        Adjust.trackEvent(event)
    }

    /// 添加普通埋点事件
    /// - Parameters:
    ///   - token: Adjust event token
    ///   - uid: 用户ID
    class func addEvent(token: String, uid: String = "") {
        let event = ADJEvent(eventToken: token)
        if !uid.isEmpty {
            event?.addCallbackParameter("uid", value: uid)
            // 用户登录后首条带 uid 的事件触发时绑定 external_id。
            // 多次调用相同值是幂等操作；换账号登录时新 uid 的 sha256 会自动覆盖旧值。
            AsyncProfile91e(uid: uid)
        }
        if let attribution = Adjust.attribution() {
            if let trackerToken = attribution.trackerToken, !trackerToken.isEmpty {
                event?.addCallbackParameter("tracker_token", value: trackerToken)
            }
            if let campaign = attribution.campaign, !campaign.isEmpty {
                event?.addCallbackParameter("campaign", value: campaign)
            }
            if let adgroup = attribution.adgroup, !adgroup.isEmpty {
                event?.addCallbackParameter("adgroup", value: adgroup)
            }
        }
        Adjust.trackEvent(event)
    }

    /// 将 uid 的 SHA-256 哈希值绑定为 Meta 归因的 external_id。
    /// 必须与服务端 S2S 上报 Meta CAPI 时使用的哈希值完全一致。
    private class func AsyncProfile91e(uid: String) {
        let hashed = throttleData952(uid)
        Adjust.addSessionPartnerParameter("external_id", value: hashed)
    }

    /// SHA-256 哈希，输出小写十六进制字符串（与服务端保持一致）
    private class func throttleData952(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
