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
    func setupAdjEnv() {
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(appToken: AdjustKey, environment: environment)
        adjustConfig?.logLevel = ADJLogLevelWarn
        adjustConfig?.delegate = self
        Adjust.appDidLaunch(adjustConfig)
        AppAdjustManager.recordOEvt(tkn: AdInstallToken)
    }
}

// MARK: - Event
extension AppAdjustManager: AdjustDelegate {
    /// 获取设备id
    class func fetchAdjId() -> String {
        let adid = Adjust.adid() ?? ""
        return adid
    }
    
    /// 添加去重事件【只记录一次】
    /// - Parameter key: 事件名
    class func recordOEvt(tkn: String) {
        let event = ADJEvent(eventToken: tkn)
        event?.setTransactionId(tkn)
        Adjust.trackEvent(event)
    }

    /// 添加 内购/订阅 埋点事件
    /// - Parameters:
    ///   - token: token
    ///   - count: 价格
    class func recordPurEvt(tkn: String, cnt: Double) {
        let event = ADJEvent(eventToken: tkn)
        event?.setRevenue(cnt, currency: "USD")
        Adjust.trackEvent(event)
    }

    /// 添加埋点事件
    /// - Parameter key: 事件名
    class func recordEvt(tkn: String) {
        let event = ADJEvent(eventToken: tkn)
        Adjust.trackEvent(event)
    }
}
