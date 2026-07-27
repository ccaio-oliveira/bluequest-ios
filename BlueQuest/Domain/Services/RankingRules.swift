//
//  RankingRules.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation

struct RankingEntry: Equatable {
    let participant: Participant
    let points: Int
    let position: Int
}

enum RankingRules {
    static func rank(participants: [Participant], completions: [Completion]) -> [RankingEntry] {
        let pointsByParticipant = Dictionary(grouping: completions, by: \.participantID).mapValues { $0.reduce(0) { $0 + $1.pointsAwarded } }
        let sorted = participants.sorted {
            (pointsByParticipant[$0.id] ?? 0) > (pointsByParticipant[$1.id] ?? 0)
        }
        
        var entries: [RankingEntry] = []
        var previousPoints: Int?
        var previousPosition = 0
        
        for (index, participant) in sorted.enumerated() {
            let points = pointsByParticipant[participant.id] ?? 0
            let position = (previousPoints == points) ? previousPosition : index + 1
            
            entries.append(RankingEntry(participant: participant, points: points, position: position))
            previousPoints = points
            previousPosition = position
        }
        
        return entries
    }
    
    static func personalEntry(for userID: Int, in entries: [RankingEntry]) -> RankingEntry? {
        entries.first { $0.participant.userID == userID }
    }
}
