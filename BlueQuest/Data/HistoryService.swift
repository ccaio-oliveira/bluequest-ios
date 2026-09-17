//
//  HistoryService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation

final class HistoryService {
    static let shared = HistoryService()
    
    private let client = APIClient.shared
    
    private init() {}
    
    func month(_ month: String) async throws -> HistoryMonth {
        let dto: HistoryResponseDTO = try await client.get("history", query: ["month": month])
        
        return HistoryMonth(
            month: dto.month,
            firstMonth: dto.firstMonth,
            lastMonth: dto.lastMonth,
            totals: HistoryTotals(
                completions: dto.totals.completions,
                points: dto.totals.points,
                streakDays: dto.totals.streakDays
            ),
            days: dto.days.map { day in
                HistoryDay(
                    date: day.date,
                    total: day.total,
                    completed: day.completed,
                    expired: day.expired,
                    points: day.points,
                    hasPhoto: day.hasPhoto,
                    tasks: day.tasks.map { task in
                        HistoryTask(
                            name: task.name,
                            challengeName: task.challengeName,
                            points: task.points,
                            state: OccurrenceState(apiValue: task.state) ?? .expired,
                            deadlineText: CalendarDayFormatter.timeText(from: task.deadlineTime),
                            hasPhoto: task.hasPhoto
                        )
                    }
                )
            }
        )
    }
}

private struct HistoryResponseDTO: Decodable {
    let month: String
    let firstMonth: String
    let lastMonth: String
    let totals: HistoryTotalsDTO
    let days: [HistoryDayDTO]
}

private struct HistoryTotalsDTO: Decodable {
    let completions: Int
    let points: Int
    let streakDays: Int
}

private struct HistoryDayDTO: Decodable {
    let date: String
    let total: Int
    let completed: Int
    let expired: Int
    let points: Int
    let hasPhoto: Bool
    let tasks: [HistoryTaskDTO]
}

private struct HistoryTaskDTO: Decodable {
    let name: String
    let challengeName: String
    let points: Int
    let state: String
    let deadlineTime: String
    let hasPhoto: Bool
}

struct HistoryTask {
    let name: String
    let challengeName: String
    let points: Int
    let state: OccurrenceState
    let deadlineText: String
    let hasPhoto: Bool
}

struct HistoryDay {
    let date: String
    let total: Int
    let completed: Int
    let expired: Int
    let points: Int
    let hasPhoto: Bool
    let tasks: [HistoryTask]
}

struct HistoryTotals {
    let completions: Int
    let points: Int
    let streakDays: Int
}

struct HistoryMonth {
    let month: String
    let firstMonth: String
    let lastMonth: String
    let totals: HistoryTotals
    let days: [HistoryDay]
}
