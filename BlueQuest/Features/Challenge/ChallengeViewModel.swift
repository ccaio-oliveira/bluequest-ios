//
//  ChallengeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation

@MainActor
final class ChallengeViewModel {
    private(set) var header: ChallengeHeader
    private(set) var ranking: [ChallengeRankingRow] = []
    private(set) var personalStats = ChallengePersonalStats(points: 0, position: 0, completedCount: 0, streakDays: 0, expiredCount: 0)
    private(set) var participantRows: [ChallengeParticipantRow] = []
    private(set) var taskRows: [ChallengeTaskRow] = []
    
    private let calendar = Calendar(identifier: .gregorian)
    private let now: Date
    private let currentUserID = 1
    
    private let challenge: Challenge
    private let participants: [Participant]
    private let userNames: [Int: String]
    private let completions: [Completion]
    
    private let challengeTasks: [Task]
    
    private lazy var joinedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    init(challengeID: Int) {
        let calendar = self.calendar
        now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 21))!
        
        challenge = Challenge(
            id: challengeID,
            name: "Projeto Verão",
            description: "",
            startDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 1))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 30))!,
            creatorUserID: 1
        )
        
        participants = [
            Participant(id: 1, userID: 1, challengeID: challengeID, joinedAt: challenge.startDate),
            Participant(id: 2, userID: 10, challengeID: challengeID, joinedAt: challenge.startDate),
            Participant(id: 3, userID: 30, challengeID: challengeID, joinedAt: challenge.startDate),
            Participant(id: 4, userID: 40, challengeID: challengeID, joinedAt: challenge.startDate)
        ]
        
        userNames = [1: "Fernanda", 10: "Ana", 30: "Caio", 40: "João"]
        
        completions = Self.makeCompletions(
            totals: [1: 218, 2: 230, 3: 194, 4: 182],
            startDate: challenge.startDate,
            calendar: calendar
        )
        
        header = ChallengeHeader(name: "", subtitle: "", day: 0, totalDays: 0, remainingText: "")
        
        challengeTasks = [
            Task(id: 1, challengeID: challengeID, name: "Beber 2L de água", description: nil, points: 2, recurrence: .daily, deadlineTime: DateComponents(hour: 23, minute: 59), requiresPhoto: .none),
            Task(id: 2, challengeID: challengeID, name: "Fazer treino", description: nil, points: 5, recurrence: .weekdays([.monday, .tuesday, .thursday, .friday]), deadlineTime: DateComponents(hour: 22, minute: 0), requiresPhoto: .optional),
            Task(id: 3, challengeID: challengeID, name: "Cardio", description: nil, points: 3, recurrence: .weekdays([.monday, .wednesday, .friday]), deadlineTime: DateComponents(hour: 22, minute: 0), requiresPhoto: .none)
        ]
        
        rebuild()
    }
    
    private func rebuild() {
        let entries = RankingRules.rank(participants: participants, completions: completions)
        
        ranking = entries.map { entry in
            ChallengeRankingRow(
                position: entry.position,
                name: userNames[entry.participant.userID] ?? "-",
                points: entry.points,
                isYou: entry.participant.userID == currentUserID
            )
        }
        
        let day = ChallengeRules.currentDay(for: challenge, now: now, calendar: calendar)
        let total = ChallengeRules.totalDays(for: challenge, calendar: calendar)
        let remaining = max(total - day, 0)
        
        header = ChallengeHeader(name: challenge.name, subtitle: "1-30 ago · \(participants.count) participantes", day: day, totalDays: total, remainingText: remaining == 0 ? "último dia" : "termina em \(remaining) dias")
        
        let myEntry = RankingRules.personalEntry(for: currentUserID, in: entries)
        let myParticipantID = participants.first { $0.userID == currentUserID }?.id
        
        personalStats = ChallengePersonalStats(
            points: myEntry?.points ?? 0,
            position: myEntry?.position ?? 0,
            completedCount: completions.filter { $0.participantID == myParticipantID }.count,
            streakDays: 6,
            expiredCount: 7
        )
        
        participantRows = entries.map { entry in
            ChallengeParticipantRow(
                name: userNames[entry.participant.userID] ?? "-",
                joinedText: joinedFormatter.string(from: entry.participant.joinedAt).replacingOccurrences(of: ".", with: ""),
                points: entry.points,
                isCreator: entry.participant.userID == challenge.creatorUserID,
                isYou: entry.participant.userID == currentUserID
            )
        }.sorted { lhs, rhs in
            if lhs.isCreator != rhs.isCreator { return lhs.isCreator }
            return lhs.points > rhs.points
        }
        
        taskRows = challengeTasks.map { task in
            ChallengeTaskRow(
                card: TaskCardModel(
                    taskName: task.name,
                    points: task.points,
                    state: .available,
                    deadlineText: deadlineText(for: task),
                    hasPhoto: task.requiresPhoto != .none
                ),
                recurrenceText: "\(task.name.lowercased()) \(recurrenceText(for: task.recurrence))"
            )
        }
    }
    
    private static func makeCompletions(totals: [Int: Int], startDate: Date, calendar: Calendar) -> [Completion] {
        let taskPoints = [(id: 1, points: 5), (id: 2, points: 3), (id: 3, points: 2)]
        var result: [Completion] = []
        var nextID = 1
        
        for (participantID, total) in totals.sorted(by: { $0.key < $1.key }) {
            var remaining = total
            var index = 0
            
            while remaining > 0 {
                let task = taskPoints[index % taskPoints.count]
                let points = min(task.points, remaining)
                let dayOffset = index / taskPoints.count
                let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) ?? startDate
                
                result.append(Completion(
                    id: nextID,
                    participantID: participantID,
                    taskID: task.id,
                    occurrenceDate: date,
                    completedAt: date,
                    pointsAwarded: points,
                    photoURL: nil)
                )
                
                remaining -= points
                nextID += 1
                index += 1
            }
        }
        
        return result
    }
    
    private func deadlineText(for task: Task) -> String {
        guard let date = calendar.date(
            bySettingHour: task.deadlineTime.hour ?? 23,
            minute: task.deadlineTime.minute ?? 59,
            second: 0,
            of: now
        ) else { return "" }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    private func recurrenceText(for recurrence: Recurrence) -> String {
        switch recurrence {
        case .once:
            return "uma vez"
        case .daily:
            return "diária"
        case .weekdays(let days):
            let names: [Weekday: String] = [
                .sunday: "dom", .monday: "seg", .tuesday: "ter", .wednesday: "qua", .thursday: "qui", .friday: "sex", .saturday: "sáb"
            ]
            return days
                .sorted { $0.rawValue < $1.rawValue }
                .compactMap { names[$0] }
                .joined(separator: "/")
        }
    }
}

struct ChallengeRankingRow: Equatable {
    let position: Int
    let name: String
    let points: Int
    let isYou: Bool
}

struct ChallengeHeader: Equatable {
    let name: String
    let subtitle: String
    let day: Int
    let totalDays: Int
    let remainingText: String
}

struct ChallengePersonalStats: Equatable {
    let points: Int
    let position: Int
    let completedCount: Int
    let streakDays: Int
    let expiredCount: Int
}

struct ChallengeParticipantRow: Equatable {
    let name: String
    let joinedText: String
    let points: Int
    let isCreator: Bool
    let isYou: Bool
}

struct ChallengeTaskRow: Equatable {
    let card: TaskCardModel
    let recurrenceText: String
}
