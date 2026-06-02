import Foundation
import UIKit
import UserNotifications

enum AppPushBackEventType: Int {
    case localPush = 1
    case remotePush = 2
}

final class AppPushEventStore {
    static let shared = AppPushEventStore()

    /// 推送点击发生时若当前 WebView 尚未就绪，先暂存完整 payload
    private var pendingPayload: [String: Any]?

    private init() {}

    /// 统一处理通知点击事件：优先立即派发给当前 H5，若页面未就绪则缓存，待后续补发
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let request = response.notification.request
        let payload = filterForm(from: request)
        reduceEvent(payload)
    }

    private func reduceEvent(_ payload: [String: Any]) {
        DispatchQueue.main.async {
            if let currentVC = AppConfig.currentViewController() as? AppWebViewController {
                currentVC.jsEvent_onPushBack(payload)
            } else {
                self.pendingPayload = payload
            }
        }
    }

    /// 在 WebView 可用时尝试补发之前缓存的推送点击事件，避免冷启动时丢失埋点
    func flushPendingEventIfNeeded(to webVC: AppWebViewController) {
        guard let payload = pendingPayload else { return }
        pendingPayload = nil
        webVC.jsEvent_onPushBack(payload)
    }

    /// 固定按 H5 协议回传 type、uid、showText：
    /// 1 = 本地推送（本地即时/定时本地统一合并）
    /// 2 = 远程推送
    private func filterForm(from request: UNNotificationRequest) -> [String: Any] {
        let eventType: AppPushBackEventType = request.trigger is UNPushNotificationTrigger ? .remotePush : .localPush
        return [
            "type": eventType.rawValue,
            "uid": request.content.userInfo["uid"] as? String ?? "",
            "showText": request.content.body
        ]
    }
}
