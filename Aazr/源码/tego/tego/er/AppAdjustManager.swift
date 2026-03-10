//
//  AppAdjustManager.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

import Adjust


class AppAdjustManager: NSObject {
    static let shared = AppAdjustManager()
    
    func p_f2a6() {
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(appToken: AdjustKey, environment: environment)
        adjustConfig?.logLevel = ADJLogLevelWarn
        adjustConfig?.delegate = self
        Adjust.appDidLaunch(adjustConfig)
        AppAdjustManager.p_h8c2(token: AdInstallToken)
    }
}

// MARK: - Event
extension AppAdjustManager: AdjustDelegate {
    class func p_g4b9() -> String {
        let adid = Adjust.adid() ?? ""
        return adid
    }
    
    class func p_h8c2(token: String) {
        let event = ADJEvent(eventToken: token)
        event?.setTransactionId(token)
        Adjust.trackEvent(event)
    }

    class func p_i3d7(token: String, count: Double) {
        let event = ADJEvent(eventToken: token)
        event?.setRevenue(count, currency: "USD")
        Adjust.trackEvent(event)
    }

    class func p_j6e1(token: String) {
        let event = ADJEvent(eventToken: token)
        Adjust.trackEvent(event)
    }
}
