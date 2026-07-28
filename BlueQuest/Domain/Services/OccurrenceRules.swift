//
//  OccurrenceRules.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

enum OccurrenceRules {
    static func deadline(for occurrence: Occurrence, task: Task, calendar: Calendar = .current) -> Date? {
        calendar.date(
            bySettingHour: task.deadlineTime.hour ?? 23, minute: task.deadlineTime.minute ?? 59, second: 0, of: occurrence.date
        )
    }
    
    static func state(
        for occurrence: Occurrence,
        task: Task,
        isCompleted: Bool,
        now: Date,
        calendar: Calendar = .current
    ) -> OccurrenceState {
        if isCompleted {
            return .completed
        }
        
        let startOfDay = calendar.startOfDay(for: occurrence.date)
        
        guard let deadline = deadline(for: occurrence, task: task, calendar: calendar) else {
            return .expired
        }
        
        if now < startOfDay {
            return .future
        } else if now <= deadline {
            return .available
        } else {
            return .expired
        }
    }
}
