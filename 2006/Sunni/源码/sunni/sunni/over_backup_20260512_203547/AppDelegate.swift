//
//  AppDelegate.swift
//  OverseaH5
//
//  Created by DouXiu on 2025/9/23.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import AVFAudio
import FirebaseRemoteConfig

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let waitVC = WaitViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
        
        // Manual Window Setup (No Storyboard/SceneDelegate)
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = self.waitVC
        _xhssny()
        let config = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        settings.fetchTimeout = 5
        config.configSettings = settings
        config.fetch { (status, error) -> Void in
            if status == .success {
                config.activate { changed, error in
                    let remoteVersion = config.configValue(forKey: "Sunni").numberValue.intValue
                    let appVersion = Int(AppVersion.replacingOccurrences(of: ".", with: "")) ?? 0
                    if remoteVersion > appVersion { // 远程配置大于App当前版本，进入B面
                        self._ya1h5e(application)
                        
                    } else { // 展示A面
                        self._lj7lf7yphewz()
                    }
                }
            } else { // 远程配置获取失败，验证本地时间戳
                let endTimeInterval: TimeInterval = 1782050587 // 预设时间(秒)
                if Date().timeIntervalSince1970 > endTimeInterval && self._bv4tot() { // 本地时间戳大于预设时间，进入B面
                    self._ya1h5e(application)
                    
                } else { // 展示A面
                    self._lj7lf7yphewz()
                }
            }
        }
        return true
    }

    /// 是否iPAD
    private func _bv4tot() -> Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
     }
    
    /// 初始化项目
    private func _ya1h5e(_ application: UIApplication) {
        registerForRemoteNotification(application)
        AppAdjustManager.shared.initAdjust()
        // 检查是否有未完成的支付订单
        AppleIAPManager.shared.iap_checkUnfinishedTransactions()
        // 支持后台播放音乐
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        DispatchQueue.main.async {
            let vc = AppWebViewController()
            vc.urlString = "\(H5WebDomain)/dist/index.html#/?packageId=\(_bxplfi17bpmc)&safeHeight=\(AppConfig.getStatusBarHeight())"
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
    }
    
    private func _lj7lf7yphewz() {
        DispatchQueue.main.async {
            self.window?.makeKeyAndVisible()
            let tabBarController = MainTabBarController()
            // 确保 TabBar 使用浅色模式
            if #available(iOS 13.0, *) {
                tabBarController.overrideUserInterfaceStyle = .light
            }
            self.window?.rootViewController = tabBarController
        }
    }
}

// MARK: - Firebase
extension AppDelegate: MessagingDelegate {
    private func _xhssny() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    func registerForRemoteNotification(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
            })
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 注册远程通知, 将deviceToken传递过去
        let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
        print("APNS Token = \(deviceStr)")
        Messaging.messaging().token { token, error in
            if let error = error {
                print("error = \(error)")
            } else if let token = token {
                print("token = \(token)")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.newData)
    }
  
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // 注册推送失败回调
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError = \(error.localizedDescription)")
    }
    
    public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        print("didReceiveRegistrationToken = \(dataDict)")
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict)
    }
}
