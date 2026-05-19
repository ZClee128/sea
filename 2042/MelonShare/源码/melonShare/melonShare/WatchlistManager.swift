//
//  WatchlistManager.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI
import Combine

struct WatchItem: Identifiable, Codable, Hashable {
    let id: UUID // Corresponds to Drama ID
    let title: String
    let category: String
    let totalEpisodes: Int
    var currentEpisode: Int
    var status: String // "Watching", "Plan to Watch", "Completed"
    var lastUpdated: Date
    
    // Abstract stylized cover gradient matching Drama database
    let startColorHex: String
    let endColorHex: String
    let iconName: String
}

class WatchlistManager: ObservableObject {
    static let shared = WatchlistManager()
    
    @Published var items: [WatchItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    // Track custom reviews added by users locally
    @Published var customReviews: [UUID: [DramaReview]] = [:] {
        didSet {
            saveReviews()
        }
    }
    
    // Track blocked users & reported reviews for full UGC guideline compliance
    @Published var blockedUsernames: Set<String> = [] {
        didSet {
            saveBlockedUsers()
        }
    }
    
    @Published var reportedReviewIds: Set<UUID> = [] {
        didSet {
            saveReportedReviews()
        }
    }
    
    private let itemsKey = "melonshare_watchlist_items"
    private let reviewsKey = "melonshare_custom_reviews"
    private let blockedKey = "melonshare_blocked_users"
    private let reportedKey = "melonshare_reported_reviews"
    
    private init() {
        loadItems()
        loadReviews()
        loadBlockedUsers()
        loadReportedReviews()
    }
    
    // MARK: - Watchlist operations
    func track(_ drama: Drama, status: String = "Watching", episode: Int = 1) {
        if let index = items.firstIndex(where: { $0.id == drama.id }) {
            items[index].status = status
            items[index].currentEpisode = min(max(episode, 1), drama.episodesCount)
            if items[index].currentEpisode == drama.episodesCount {
                items[index].status = "Completed"
            }
            items[index].lastUpdated = Date()
        } else {
            let newItem = WatchItem(
                id: drama.id,
                title: drama.title,
                category: drama.category,
                totalEpisodes: drama.episodesCount,
                currentEpisode: min(max(episode, 1), drama.episodesCount),
                status: episode == drama.episodesCount ? "Completed" : status,
                lastUpdated: Date(),
                startColorHex: drama.startColorHex,
                endColorHex: drama.endColorHex,
                iconName: drama.iconName
            )
            items.append(newItem)
        }
    }
    
    func updateEpisode(for dramaId: UUID, to episode: Int) {
        if let index = items.firstIndex(where: { $0.id == dramaId }) {
            let total = items[index].totalEpisodes
            let nextEp = min(max(episode, 1), total)
            items[index].currentEpisode = nextEp
            if nextEp == total {
                items[index].status = "Completed"
            } else if items[index].status == "Completed" && nextEp < total {
                items[index].status = "Watching"
            }
            items[index].lastUpdated = Date()
            objectWillChange.send()
        }
    }
    
    func removeFromWatchlist(_ dramaId: UUID) {
        items.removeAll(where: { $0.id == dramaId })
    }
    
    func isTracking(_ dramaId: UUID) -> Bool {
        items.contains(where: { $0.id == dramaId })
    }
    
    func getTrackedItem(_ dramaId: UUID) -> WatchItem? {
        items.first(where: { $0.id == dramaId })
    }
    
    // MARK: - Review operations
    func addReview(for dramaId: UUID, username: String, rating: Int, content: String) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: Date())
        
        let newReview = DramaReview(
            username: username.isEmpty ? "Anonymous" : username,
            rating: rating,
            date: dateString,
            content: content
        )
        
        var reviewsList = customReviews[dramaId] ?? []
        reviewsList.insert(newReview, at: 0)
        customReviews[dramaId] = reviewsList
    }
    
    func getAllReviews(for drama: Drama) -> [DramaReview] {
        let customList = customReviews[drama.id] ?? []
        let combined = customList + drama.reviews
        return combined.filter { !blockedUsernames.contains($0.username) && !reportedReviewIds.contains($0.id) }
    }
    
    func blockUser(_ username: String) {
        blockedUsernames.insert(username)
        objectWillChange.send()
    }
    
    func reportReview(_ reviewId: UUID) {
        reportedReviewIds.insert(reviewId)
        objectWillChange.send()
    }
    
    // MARK: - Local storage
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([WatchItem].self, from: data) {
            self.items = decoded
        }
    }
    
    private func saveReviews() {
        let codableDict = customReviews.mapValues { reviews in
            reviews.map { CodableReview(username: $0.username, rating: $0.rating, date: $0.date, content: $0.content) }
        }
        if let encoded = try? JSONEncoder().encode(codableDict) {
            UserDefaults.standard.set(encoded, forKey: reviewsKey)
        }
    }
    
    private func loadReviews() {
        if let data = UserDefaults.standard.data(forKey: reviewsKey),
           let decoded = try? JSONDecoder().decode([UUID: [CodableReview]].self, from: data) {
            self.customReviews = decoded.mapValues { codables in
                codables.map { DramaReview(username: $0.username, rating: $0.rating, date: $0.date, content: $0.content) }
            }
        }
    }
    
    private func saveBlockedUsers() {
        let array = Array(blockedUsernames)
        UserDefaults.standard.set(array, forKey: blockedKey)
    }
    
    private func loadBlockedUsers() {
        if let array = UserDefaults.standard.stringArray(forKey: blockedKey) {
            blockedUsernames = Set(array)
        }
    }
    
    private func saveReportedReviews() {
        let array = Array(reportedReviewIds).map { $0.uuidString }
        UserDefaults.standard.set(array, forKey: reportedKey)
    }
    
    private func loadReportedReviews() {
        if let array = UserDefaults.standard.stringArray(forKey: reportedKey) {
            reportedReviewIds = Set(array.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func clearAllData() {
        items = []
        customReviews = [:]
        blockedUsernames = []
        reportedReviewIds = []
        UserDefaults.standard.removeObject(forKey: itemsKey)
        UserDefaults.standard.removeObject(forKey: reviewsKey)
        UserDefaults.standard.removeObject(forKey: blockedKey)
        UserDefaults.standard.removeObject(forKey: reportedKey)
    }
    
}

// Codable helper struct for serializing reviews
struct CodableReview: Codable {
    let username: String
    let rating: Int
    let date: String
    let content: String
}
