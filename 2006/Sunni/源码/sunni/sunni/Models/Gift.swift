//
//  Gift.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation

struct Gift: Identifiable, Codable {
    let id: UUID
    let name: String
    let icon: String
    let coinCost: Int
    
    init(id: UUID = UUID(), name: String, icon: String, coinCost: Int) {
        self.id = id
        self.name = name
        self.icon = icon
        self.coinCost = coinCost
    }
    
    // Pre-defined gift catalog
    static let catalog: [Gift] = [
        Gift(name: "Heart", icon: "❤️", coinCost: 10),
        Gift(name: "Rose", icon: "🌹", coinCost: 50),
        Gift(name: "Trophy", icon: "🏆", coinCost: 100),
        Gift(name: "Star", icon: "⭐", coinCost: 20),
        Gift(name: "Diamond", icon: "💎", coinCost: 500),
        Gift(name: "Crown", icon: "👑", coinCost: 1000),
        Gift(name: "Fire", icon: "🔥", coinCost: 30),
        Gift(name: "Clap", icon: "👏", coinCost: 15),
        Gift(name: "Sparkles", icon: "✨", coinCost: 25)
    ]
}
