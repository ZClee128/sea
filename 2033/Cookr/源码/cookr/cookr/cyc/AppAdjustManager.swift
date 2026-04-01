//
//  AppAdjustManager.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

import Adjust


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
}
