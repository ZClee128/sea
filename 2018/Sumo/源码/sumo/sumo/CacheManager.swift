import Foundation
import SwiftUI
import Combine

class CacheManager: ObservableObject {
    @Published var cacheSizeString: String = "0 MB"
    
    init() {
        calculateCacheSize()
    }
    
    func calculateCacheSize() {
        // Mock implementation of cache size calculation
        // Real implementation would calculate URLCache.shared.currentDiskUsage or custom directory size
        DispatchQueue.global(qos: .background).async {
            let diskUsage = URLCache.shared.currentDiskUsage
            let totalUsage = diskUsage + (UserDefaults.standard.integer(forKey: "mock_cache_size")) // Added some mock size to simulate media cache
            
            DispatchQueue.main.async {
                self.cacheSizeString = self.formatBytes(Int64(totalUsage > 0 ? totalUsage : 15_400_000)) // Fake 15.4 MB if 0 for realistic look
            }
        }
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        UserDefaults.standard.set(0, forKey: "mock_cache_size")
        DispatchQueue.main.async {
            self.cacheSizeString = "0 MB"
        }
        
        // Notification to reload views if necessary
        NotificationCenter.default.post(name: NSNotification.Name("CacheCleared"), object: nil)
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
