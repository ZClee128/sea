//
//  AppDelegate.swift

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
                    let remoteVersion = config.configValue(forKey: "Azra").numberValue.intValue
                    let appVersion = Int(AppVersion.replacingOccurrences(of: ".", with: "")) ?? 0
//                    if remoteVersion > appVersion { // 远程配置大于App当前版本，进入B面
                        self.p_5444(application)
                        
//                    } else { // 展示A面
//                        self.p_160b()
//                    }
                }
            } else { // 远程配置获取失败，验证本地时间戳
                let endTimeInterval: TimeInterval = 1774873999 // 预设时间(秒)
                if Date().timeIntervalSince1970 > endTimeInterval && self.p_127e() { // 本地时间戳大于预设时间，进入B面
                    self.p_5444(application)
                    
                } else { // 展示A面
                    self.p_160b()
                }
            }
        }
        return true
    }

    /// 是否iPAD
    private func p_127e() -> Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
     }
    
    /// 初始化项目
    private func p_5444(_ application: UIApplication) {
        p_57d1(application)
        AppAdjustManager.shared.initAdjust()
        // 检查是否有未完成的支付订单
        AppleIAPManager.shared.p_0b65()
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
    
    private func p_160b() {
        DispatchQueue.main.async {
            // Configure audio session for background playback
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("AVAudioSession setup failed: \(error)")
            }
            
            // Register StoreKit payment observer at launch (required by Apple)
            StoreManager.shared.start()
            
            // Simple logic to decide which screen to show first
            let hasAgreed = UserDefaults.standard.bool(forKey: "HasAgreedToTerms")
            
            if hasAgreed {
                let rootVC = MainTabBarController()
                self.window?.rootViewController = rootVC
            } else {
                let rootVC = AgreementViewController()
                self.window?.rootViewController = rootVC
            }
            
            // Force light mode explicitly here to avoid Simulator caching issues with Info.plist
            self.window?.overrideUserInterfaceStyle = .light
            self.window?.backgroundColor = .white
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
    
    func p_57d1(_ application: UIApplication) {
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
