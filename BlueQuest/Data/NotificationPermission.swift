//
//  NotificationPermission.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation
import UserNotifications

enum NotificationPermission {
    static func status() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
    
    static func request() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
}
