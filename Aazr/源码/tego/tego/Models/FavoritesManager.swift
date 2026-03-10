//
//  FavoritesManager.swift
//  tego
//

import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    @Published var savedTrendIDs: Set<String> = []
    
    private let defaultsKey = "saved_trend_ids_v2"
    
    static let shared = FavoritesManager()
    
    init() {
        loadFavorites()
    }
    
    func toggleFavorite(for trend: AppTrend) {
        if savedTrendIDs.contains(trend.id) {
            savedTrendIDs.remove(trend.id)
        } else {
            savedTrendIDs.insert(trend.id)
        }
        saveFavorites()
    }
    
    func isFavorite(trend: AppTrend) -> Bool {
        return savedTrendIDs.contains(trend.id)
    }
    
    private func saveFavorites() {
        let stringArray = Array(savedTrendIDs)
        UserDefaults.standard.set(stringArray, forKey: defaultsKey)
    }
    
    private func loadFavorites() {
        if let stringArray = UserDefaults.standard.stringArray(forKey: defaultsKey) {
            savedTrendIDs = Set(stringArray)
        }
    }
}
