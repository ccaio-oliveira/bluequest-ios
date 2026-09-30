//
//  NotificationService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation

final class NotificationService {
    static let shared = NotificationService()
    
    private let client = APIClient.shared
    
    private init() {}
    
    func list() async throws -> [AppNotification] {
        let dto: NotificationListDTO = try await client.get("notifications")
        
        return dto.items.map { item in
            AppNotification(
                id: item.id,
                kind: item.kind,
                challengeID: item.challengeId,
                title: item.title,
                message: item.message,
                createdAt: item.createdAt,
                isRead: item.read
            )
        }
    }
    
    func unreadCount() async throws -> Int {
        let dto: UnreadCountDTO = try await client.get("notifications/unread-count")
        return dto.unreadCount
    }
    
    func markAllRead() async throws {
        try await client.postWithoutResponse("notifications/read")
    }
    
    func preferences() async throws -> NotificationPreferences {
        try await client.get("notification-preferences")
    }
    
    func updatePreferences(_ preferences: NotificationPreferences) async throws {
        try await client.put("notification-preferences", body: preferences)
    }
}

struct AppNotification: Equatable {
    let id: String
    let kind: String
    let challengeID: Int?
    let title: String
    let message: String
    let createdAt: Date
    let isRead: Bool
}

struct NotificationPreferences: Codable, Equatable {
    var dailyReminder: Bool
    var deadline: Bool
    var weeklyMandatory: Bool
    var joined: Bool
    var ranking: Bool
    var ended: Bool
}

private struct NotificationListDTO: Decodable {
    let items: [NotificationItemDTO]
}

private struct NotificationItemDTO: Decodable {
    let id: String
    let kind: String
    let challengeId: Int?
    let title: String
    let message: String
    let createdAt: Date
    let read: Bool
}

private struct UnreadCountDTO: Decodable {
    let unreadCount: Int
}
