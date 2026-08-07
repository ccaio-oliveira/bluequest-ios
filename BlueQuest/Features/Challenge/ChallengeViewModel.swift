//
//  ChallengeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation

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

@MainActor
final class ChallengeViewModel {
    private(set) var header: ChallengeHeader
    private(set) var ranking: [ChallengeRankingRow] = []
    
    private let calendar = Calendar(identifier: .gregorian)
    private let now: Date
    private let currentUserID = 1
    
    private let challenge: Challenge
    private let participants: [Participant]
    private let userNames: [Int: String]
    private let completions: [Completion]
    
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
        
        completions = Self.makeCompletions(totals: [1: 218, 2: 230, 3: 194, 4: 182])
        
        header = ChallengeHeader(name: "", subtitle: "", day: 0, totalDays: 0, remainingText: "")
        
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
    }
    
    private static func makeCompletions(totals: [Int: Int]) -> [Completion] {
        let taskPoints = [5, 3, 2]
        var result: [Completion] = []
        var nextID = 1
        
        for (participantID, total) in totals.sorted(by: { $0.key < $1.key }) {
            var remaining = total
            var index = 0
            
            while remaining > 0 {
                let points = min(taskPoints[index % taskPoints.count], remaining)
                
                result.append(Completion(id: nextID, participantID: participantID, occurrenceID: nextID, date: Date(), pointsAwarded: points, photoURL: nil))
                
                remaining -= points
                nextID += 1
                index += 1
            }
        }
        
        return result
    }
}
