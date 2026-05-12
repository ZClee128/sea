//
//  Report.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation

enum ReportType: String, Codable {
    case post
    case user
}

enum ReportReason: String, Codable, CaseIterable {
    case spam = "Spam"
    case inappropriate = "Inappropriate Content"
    case harassment = "Harassment"
    case falseInfo = "False Information"
    case other = "Other"
}

struct Report: Codable, Identifiable {
    let id: String
    let reporterId: String
    let type: ReportType
    let targetId: String
    var reason: ReportReason
    var description: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        type: ReportType,
        targetId: UUID,
        reporterId: UUID,
        reason: ReportReason,
        details: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id.uuidString
        self.reporterId = reporterId.uuidString
        self.type = type
        self.targetId = targetId.uuidString
        self.reason = reason
        self.description = details
        self.createdAt = createdAt
    }
}
