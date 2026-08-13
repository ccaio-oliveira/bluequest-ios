//
//  HomeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation

@MainActor
final class HomeViewModel {
    private(set) var rows: [HomeTaskRow] = []
    private(set) var header = HomeHeader(dateText: "", points: 0, completedCount: 0, doableCount: 0)
    private(set) var challenges: [HomeChallengeRow] = []
    
    var onChange: (() -> Void)?
    var onPointsAwarded: ((Int) -> Void)?
    
    private let calendar = Calendar(identifier: .gregorian)
    private let now: Date
    
    private let participant: Participant
    private let tasks: [ChallengeTask]
    private let occurrences: [Occurrence]
    private var completions: [Completion]
    private let mockChallenges: [Challenge]
    
    private lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d MMM"
        return formatter
    }()
    
    private lazy var dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    init() {
        let today = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        self.now = calendar.date(byAdding: .hour, value: 21, to: today)!
        
        participant = Participant(id: 1, userID: 1, challengeID: 1, joinedAt: today)
        
        tasks = [
            ChallengeTask(id: 1, challengeID: 1, name: "Beber 2L de água", points: 2, recurrence: .daily, deadlineTime: DateComponents(hour: 21, minute: 30), requiresPhoto: .none),
            
            ChallengeTask(id: 2, challengeID: 1, name: "Treinar", points: 5, recurrence: .daily, deadlineTime: DateComponents(hour: 21, minute: 30), requiresPhoto: .optional),
            
            ChallengeTask(id: 3, challengeID: 1, name: "Cardio", points: 3, recurrence: .daily, deadlineTime: DateComponents(hour: 20, minute: 0), requiresPhoto: .none)
        ]
        
        occurrences = tasks.map { Occurrence(taskID: $0.id, date: today) }
        
        completions = [
            Completion(id: 1, participantID: 1, taskID: 1,occurrenceDate: today, completedAt: now, pointsAwarded: 2, photoURL: nil)
        ]
        
        mockChallenges = [
            Challenge(id: 1, name: "Projeto Verão", description: "", startDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 1))!, endDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 30))!, creatorUserID: 1),
            Challenge(id: 2, name: "21 Dias de Estudos", description: "", startDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 10))!, endDate: calendar.date(from: DateComponents(year: 2026, month: 8, day: 31))!, creatorUserID: 2)
        ]
        
        rebuildRows()
    }
    
    func completeTask(taskID: Int) {
        guard let occurrence = occurrences.first(where: { $0.taskID == taskID }),
              let task = tasks.first(where: { $0.id == occurrence.taskID }) else { return }
        
        let isCompleted = occurrence.isCompleted(in: completions, calendar: calendar)
        
        do {
            try CompletionRules.validateCompletion(occurrence: occurrence, task: task, isCompleted: isCompleted, requestingUserIsParticipant: true, now: now, calendar: calendar)
        } catch {
            return // Fase futura: expor esse erro pra UI mostrar uma mensagem
        }
        
        let newCompletion = Completion(id: completions.count + 1, participantID: participant.id, taskID: taskID, occurrenceDate: occurrence.date, completedAt: now, pointsAwarded: task.points, photoURL: nil)
        
        completions.append(newCompletion)
        rebuildRows()
        onChange?()
        onPointsAwarded?(task.points)
    }
    
    func logout() async {
        try? await AuthService.shared.logout()
        Session.shared.end()
    }
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private func rebuildRows() {
        rows = occurrences.map { occurrence in
            let task = tasks.first { $0.id == occurrence.taskID }!
            let isCompleted = occurrence.isCompleted(in: completions, calendar: calendar)
            let state = OccurrenceRules.state(for: occurrence, task: task, isCompleted: isCompleted, now: now, calendar: calendar)
            
            let deadline = OccurrenceRules.deadline(for: occurrence, task: task, calendar: calendar)
            
            return HomeTaskRow(
                taskID: occurrence.taskID,
                card: TaskCardModel(
                    taskName: task.name,
                    points: task.points,
                    state: state,
                    deadlineText: deadline.map { timeFormatter.string(from: $0) } ?? "",
                    hasPhoto: task.requiresPhoto != .none
                )
            )
        }
        
        rebuildHeader()
        rebuildChallenges()
    }
    
    private func rebuildHeader() {
        let raw = dayFormatter.string(from: now)
            .replacingOccurrences(of: "-feira", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        let weekday = raw.prefix(1).uppercased() + raw.dropFirst()
        
        header = HomeHeader(dateText: "Hoje . \(weekday)", points: completions.filter { calendar.isDate($0.occurrenceDate, inSameDayAs: now) }.reduce(0) { $0 + $1.pointsAwarded }, completedCount: rows.filter { $0.card.state == .completed }.count, doableCount: rows.filter { $0.card.state != .future }.count)
    }
    
    private func rebuildChallenges() {
        let mockPoints = [1: 118, 2: 34]
        let mockRanks: [Int: Int] = [1: 2]
        let mockParticipants = [
            1: ["Ana", "Fernanda", "Caio", "João"],
            2: ["Bia", "Leo"]
        ]
        
        challenges = mockChallenges.enumerated().map { index, challenge in
            let state = ChallengeRules.state(for: challenge, now: now, calendar: calendar)
            
            return HomeChallengeRow(
                id: challenge.id,
                name: challenge.name,
                periodText: periodText(for: challenge),
                day: ChallengeRules.currentDay(for: challenge, now: now, calendar: calendar),
                totalDays: ChallengeRules.totalDays(for: challenge, calendar: calendar),
                points: (mockPoints[challenge.id] ?? 0) + (challenge.id == 1 ? header.points : 0),
                rank: mockRanks[challenge.id],
                participantNames: mockParticipants[challenge.id] ?? [],
                state: state,
                isHero: index == 0
            )
        }
    }
    
    private func periodText(for challenge: Challenge) -> String {
        let sameMonth = calendar.isDate(challenge.startDate, equalTo: challenge.endDate, toGranularity: .month)
        let end = dayMonthFormatter.string(from: challenge.endDate).replacingOccurrences(of: ".", with: "")
        
        if sameMonth {
            let startDay = calendar.component(.day, from: challenge.startDate)
            return "\(startDay)-\(end)"
        } else {
            let start = dayMonthFormatter.string(from: challenge.startDate).replacingOccurrences(of: ".", with: "")
            return "\(start) – \(end)"
        }
    }
}

struct HomeTaskRow: Equatable {
    let taskID: Int
    let card: TaskCardModel
}

struct HomeHeader: Equatable {
    let dateText: String
    let points: Int
    let completedCount: Int
    let doableCount: Int
}

struct HomeChallengeRow: Equatable {
    let id: Int
    let name: String
    let periodText: String
    let day: Int
    let totalDays: Int
    let points: Int
    let rank: Int?
    let participantNames: [String]
    let state: ChallengeState
    let isHero: Bool
}
