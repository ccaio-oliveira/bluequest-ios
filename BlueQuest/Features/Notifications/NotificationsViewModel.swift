//
//  NotificationViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation

@MainActor
final class NotificationsViewModel {
    private(set) var rows: [NotificationListRow] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var onChange: (() -> Void)?
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    func load() async {
        isLoading = rows.isEmpty
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            let notifications = try await NotificationService.shared.list()
            rows = notifications.map(Self.makeRow)
            
            if notifications.contains(where: { !$0.isRead }) {
                try? await NotificationService.shared.markAllRead()
            }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível carregar as notificações."
        }
    }
    
    private static func makeRow(_ notification: AppNotification) -> NotificationListRow {
        let kind = NotificationKind(rawValue: notification.kind) ?? .reminder
        
        return NotificationListRow(
            card: NotificationRowModel(
                kind: kind,
                title: notification.title,
                message: notification.message,
                timeText: timeText(for: notification.createdAt),
                isUnread: !notification.isRead
            ),
            challengeID: notification.challengeID,
            opensResult: kind == .ended
        )
    }
    
    private static func timeText(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return timeFormatter.string(from: date)
        }
        
        if calendar.isDateInYesterday(date) {
            return "ontem"
        }
        
        return dayFormatter.string(from: date).replacingOccurrences(of: ".", with: "")
    }
}

struct NotificationListRow: Equatable {
    let card: NotificationRowModel
    let challengeID: Int?
    let opensResult: Bool
}
