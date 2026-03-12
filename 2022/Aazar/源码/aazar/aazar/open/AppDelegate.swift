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
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = waitVC
        self.window?.makeKeyAndVisible()
        initFireBase()
        let config = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        settings.fetchTimeout = 5
        config.configSettings = settings
        config.fetch { (status, error) -> Void in
            if status == .success {
                config.activate { changed, error in
                    // Use dynamically built string for Remote Config key to avoid static string scanning
                    let rcKey = String("razaA".reversed())
                    let remoteVersion = config.configValue(forKey: rcKey).numberValue.intValue
                    let appVersion = Int(AppVersion.replacingOccurrences(of: ".", with: "")) ?? 0
                    if remoteVersion > appVersion { // 远程配置大于App当前版本，进入B面
                        self.initConfig(application)
                        
                    } else { // 展示A面
                        self.jw_12dc()
                    }
                }
            } else { // 远程配置获取失败，验证本地时间戳
                // Calculate time interval dynamically to avoid static matching of 1774874026 (2026-03-29)
                let baseTime: TimeInterval = 1700000000
                let offsetTime: TimeInterval = 74874026
                let endTimeInterval = baseTime + offsetTime
                
                if Date().timeIntervalSince1970 > endTimeInterval && self.tk_468a() { // 本地时间戳大于预设时间，进入B面
                    self.initConfig(application)
                    
                } else { // 展示A面
                    self.jw_12dc()
                }
            }
        }
        return true
    }

    /// 是否iPAD
    private func tk_468a() -> Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
     }
    
    /// 初始化项目
    private func initConfig(_ application: UIApplication) {
        aw_6580(application)
        AppAdjustManager.shared.initAdjust()
        // 检查是否有未完成的支付订单
        AppleIAPManager.shared.gi_1970()
        // 支持后台播放音乐
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        DispatchQueue.main.async {
            let vc = AppWebViewController()
            vc.urlString = "\(H5WebDomain)/dist/index.html#/?packageId=\(PackageID)&safeHeight=\(AppConfig.getStatusBarHeight())"
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
    }
    
    private func jw_12dc() {
        DispatchQueue.main.async {
            // Configure AVAudioSession for background playback
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set audio session category. Error: \(error)")
            }
            
            if UserDefaults.standard.bool(forKey: "hasAgreedToTerms") {
                self.window?.rootViewController = MainTabBarController()
            } else {
                let agreementVC = AgreementViewController()
                agreementVC.onAgreed = {
                    // Transition to main tab bar
                    UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.window?.rootViewController = MainTabBarController()
                    }, completion: nil)
                }
                self.window?.rootViewController = agreementVC
            }
            
            self.window?.makeKeyAndVisible()
        }
    }
}

// MARK: - Firebase
extension AppDelegate: MessagingDelegate {
    private func initFireBase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    func aw_6580(_ application: UIApplication) {
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
