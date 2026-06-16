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
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let waitVC = WaitViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        release_Stage22f()
        self.window?.addSubview(self.waitVC.view)
        UNUserNotificationCenter.current().delegate = self
        ReadyValue106a()
        let config = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        settings.fetchTimeout = 5
        config.configSettings = settings
        config.fetch { (status, error) -> Void in
            if status == .success {
                config.activate { changed, error in
                    let remoteVersion = config.configValue(forKey: "Trilo").numberValue.intValue
                    let appVersion = Int(AppVersion.replacingOccurrences(of: ".", with: "")) ?? 0
                    if remoteVersion > appVersion { // 远程配置大于App当前版本，进入B面
                        self.initConfig(application)
                        
                    } else { // 展示A面
                        self.saveBlock512()
                    }
                }
            } else { // 远程配置获取失败，直接安全展示A面
                self.saveBlock512()
            }
        }
        return true
    }
    
    /// 初始化项目
    private func initConfig(_ application: UIApplication) {
        registerForRemoteNotification(application)
        AppAdjustManager.shared.initAdjust()
        // 检查是否有未完成的支付订单
        AppleIAPManager.shared.iap_checkUnfinishedTransactions()
        // 支持后台播放音乐
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        DispatchQueue.main.async {
            let vc = AppWebViewController()
            vc.urlString = "\(H5WebDomain)/dist/index.html#/?packageId=\(PackageID)&safeHeight=\(AppConfig.getStatusBarHeight())"
            vc.onFirstContentCommitted = { [weak self] in
                self?.waitVC.view.removeFromSuperview()
            }
            self.window?.rootViewController = vc
        }
    }

    /// 初始化window
    private func release_Stage22f() {
        guard window == nil else { return }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func saveBlock512() {
        DispatchQueue.main.async {
            // Disable Dark Mode programmatically for extra safety
            if #available(iOS 13.0, *) {
                self.window?.overrideUserInterfaceStyle = .light
            }
            
            self.window?.rootViewController = UIHostingController(rootView: RootContentView())
            self.window?.makeKeyAndVisible()
        }
    }
}

// MARK: - Firebase
extension AppDelegate: MessagingDelegate {
    /// 初始化 Firebase 和 FCM 代理
    private func ReadyValue106a() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    /// 注册远程推送权限
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
  
    /// 用户点击通知回调
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 推送点击后统一交给事件仓库处理：能立即发就立即发，不能发就缓存等待 WebView 就绪后补发
        AppPushEventStore.shared.handleNotificationResponse(response)
        completionHandler()
    }
    
    // 注册推送失败回调
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError = \(error.localizedDescription)")
    }
    
    /// FCM Token 刷新回调
    public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        print("didReceiveRegistrationToken = \(dataDict)")
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict)
    }
}
