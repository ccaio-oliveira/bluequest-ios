//
//  RankingRulesTests.swift
//  BlueQuestTests
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import XCTest
@testable import BlueQuest

final class RankingRulesTests: XCTestCase {
    
    private func makeParticipant(id: Int, userID: Int, challnegeID: Int = 1) -> Participant {
        Participant(id: id, userID: userID, challengeID: challnegeID, joinedAt: Date())
    }
    
    private func makeCompletion(id: Int, participantID: Int, points: Int) -> Completion {
        Completion(id: id, participantID: participantID, occurrenceID: 1, date: Date(), pointsAwarded: points, photoURL: nil)
    }
    
    func test_withNoCompletions_allParticipantsHaveZeroPoints() {
        let participants = [
            makeParticipant(id: 1, userID: 10),
            makeParticipant(id: 2, userID: 20)
        ]
        
        let result = RankingRules.rank(participants: participants, completions: [])
        
        XCTAssertEqual(result.map(\.points), [0, 0])
        XCTAssertEqual(result.map(\.position), [1, 1])
    }
    
    func test_withDifferentPoints_ordersDescending() {
        let participants = [
            makeParticipant(id: 1, userID: 10),
            makeParticipant(id: 2, userID: 20),
            makeParticipant(id: 3, userID: 30)
        ]
        
        let completions = [
            makeCompletion(id: 1, participantID: 1, points: 5),
            makeCompletion(id: 2, participantID: 2, points: 12),
            makeCompletion(id: 3, participantID: 3, points: 8)
        ]
        
        let result = RankingRules.rank(participants: participants, completions: completions)
        
        XCTAssertEqual(result.map(\.participant.id), [2, 3, 1])
        XCTAssertEqual(result.map(\.points), [12, 8, 5])
        XCTAssertEqual(result.map(\.position), [1, 2, 3])
    }
    
    func test_personalEntry_returnsMatchingParticipant() {
        let participants = [
            makeParticipant(id: 1, userID: 10),
            makeParticipant(id: 2, userID: 20)
        ]
        
        let completions = [
            makeCompletion(id: 1, participantID: 1, points: 5),
            makeCompletion(id: 2, participantID: 2, points: 12)
        ]
        
        let ranking = RankingRules.rank(participants: participants, completions: completions)
        
        let personal = RankingRules.personalEntry(for: 20, in: ranking)
        
        XCTAssertEqual(personal?.position, 1)
        XCTAssertEqual(personal?.points, 12)
    }
    
    func test_personalEntry_whenUserNotAParticipant_returnsNil() {
        let participants = [makeParticipant(id: 1, userID: 10)]
        let ranking = RankingRules.rank(participants: participants, completions: [])
        
        let personal = RankingRules.personalEntry(for: 999, in: ranking)
        
        XCTAssertNil(personal)
    }
}
