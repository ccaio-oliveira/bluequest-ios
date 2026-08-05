//
//  ChallengeRules.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 04/08/26.
//

import Foundation

enum ChallengeRules {
    static func state(for challenge: Challenge, now: Date, calendar: Calendar = .current) -> ChallengeState {
        let start = calendar.startOfDay(for: challenge.startDate)
        let dayAfterEnd = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: challenge.endDate)
        ) ?? challenge.endDate
        
        if now < start {
            return .future
        } else if now < dayAfterEnd {
            return .inProgress
        } else {
            return .closed
        }
    }
    
    static func totalDays(for challenge: Challenge, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: challenge.startDate)
        let end = calendar.startOfDay(for: challenge.endDate)
        return (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1
    }
    
    static func currentDay(for challenge: Challenge, now: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: challenge.startDate)
        let today = calendar.startOfDay(for: now)
        let elapsed = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        
        return min(max(elapsed + 1, 1), totalDays(for: challenge, calendar: calendar))
    }
}
