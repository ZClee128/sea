import Foundation

/// Manages blocked users and reported content for UGC safety compliance (App Store Guideline 1.2).
class BlocklistManager {
    static let shared = BlocklistManager()
    private init() {}

    private let blockedUsersKey = "jolo_blocked_users"
    private let reportedItemsKey = "jolo_reported_items"

    // MARK: - Blocked Users

    var blockedUsers: Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: blockedUsersKey) ?? []
        return Set(arr)
    }

    func blockUser(_ username: String) {
        var current = blockedUsers
        current.insert(username)
        UserDefaults.standard.set(Array(current), forKey: blockedUsersKey)
        // Notify feed to reload immediately
        NotificationCenter.default.post(name: .blockedUsersChanged, object: nil)
        // Notify developer (stub — replace with real API/email endpoint)
        sendDeveloperNotification(type: "block", username: username, itemId: nil)
    }

    func isBlocked(_ username: String) -> Bool {
        return blockedUsers.contains(username)
    }

    // MARK: - Reported Items

    func reportItem(itemId: String, username: String) {
        var current = UserDefaults.standard.stringArray(forKey: reportedItemsKey) ?? []
        if !current.contains(itemId) {
            current.append(itemId)
            UserDefaults.standard.set(current, forKey: reportedItemsKey)
        }
        // Notify developer of objectionable content report
        sendDeveloperNotification(type: "report", username: username, itemId: itemId)
    }

    var reportedItemIds: Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: reportedItemsKey) ?? []
        return Set(arr)
    }

    // MARK: - Developer Notification Stub

    /// Sends a notification to the developer when content is reported or a user is blocked.
    /// Replace the print statement with a real HTTP call or email trigger in production.
    private func sendDeveloperNotification(type: String, username: String, itemId: String?) {
        // TODO: Replace with real API call, e.g.:
        //   POST https://your-server.com/moderation { type, username, itemId, timestamp }
        let msg = "[Jolo Moderation] type=\(type) user=\(username) itemId=\(itemId ?? "n/a") at \(Date())"
        print(msg)
        // Example URLSession call (commented out until real endpoint is ready):
        // guard let url = URL(string: "https://api.your-server.com/moderation") else { return }
        // var request = URLRequest(url: url)
        // request.httpMethod = "POST"
        // let body = ["type": type, "username": username, "itemId": itemId ?? ""]
        // request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        // URLSession.shared.dataTask(with: request).resume()
    }
}

extension Notification.Name {
    static let blockedUsersChanged = Notification.Name("jolo.blockedUsersChanged")
}
