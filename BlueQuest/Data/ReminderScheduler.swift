//
//  ReminderScheduler.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 01/10/26.
//

import Foundation
import OSLog
import UserNotifications

enum ReminderScheduler {
    private static let limit = 60
    private static let logger = Logger(subsystem: "br.com.ctech.BlueQuest", category: "reminders")
    
    static func sync() async {
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        
        guard status == .authorized || status == .provisional else { return }
        
        let reminders: [Reminder]
        
        do {
            reminders = try await NotificationService.shared.reminders()
        } catch {
            logger.error("Não foi possível buscar o plano de lembretes: \(error.localizedDescription, privacy: .public)")
            return
        }
        
        center.removeAllPendingNotificationRequests()
        
        for reminder in reminders.prefix(limit) {
            let interval = reminder.fireAt.timeIntervalSinceNow
            guard interval > 0 else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }
    
    static func clear() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
