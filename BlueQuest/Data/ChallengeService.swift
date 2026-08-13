//
//  ChallengeService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation

private struct TodayResponseDTO: Decodable {
    let date: String
    let occurrences: [OccurrenceDTO]
}

private struct OccurrenceDTO: Decodable {
    let taskId: Int
    let challengeId: Int
    let challengeName: String
    let name: String
    let points: Int
    let photoRequirement: String
    let deadlineAt: Date
    let occurrenceDate: String
    let state: String
    let pointsAwarded: Int?
}

private struct ChallengesResponseDTO: Decodable {
    let challenges: [ChallengeSummaryDTO]
}

private struct ChallengeSummaryDTO: Decodable {
    let id: Int
    let name: String
    let startDate: String
    let endDate: String
    let state : String
    let currentDay: Int
    let totalDays: Int
    let myPoints: Int
    let myRank: Int?
    let participantsCount: Int
    let participants: [ParticipantSummaryDTO]
}

private struct ParticipantSummaryDTO: Decodable {
    let name: String
}

private struct CompleteTaskRequest: Encodable {
    let taskId: Int
    let occurrenceDate: String
}

struct TodayOccurrence {
    let taskID: Int
    let challengeID: Int
    let name: String
    let points: Int
    let pointsAwarded: Int?
    let state: OccurrenceState
    let deadline: Date
    let occurrenceDate: String
    let hasPhoto: Bool
}

struct ChallengeSummary {
    let id: Int
    let name: String
    let periodText: String
    let state: ChallengeState
    let currentDay: Int
    let totalDays: Int
    let myPoints: Int
    let myRank: Int?
    let participantsCount: Int
    let participantNames: [String]
}

final class ChallengeService {
    static let shared = ChallengeService()
    
    private let client = APIClient.shared
    
    private init() {}
    
    func today() async throws -> [TodayOccurrence] {
        let response: TodayResponseDTO = try await client.get("today")
        
        return response.occurrences.map { dto in
            TodayOccurrence(
                taskID: dto.taskId,
                challengeID: dto.challengeId,
                name: dto.name,
                points: dto.points,
                pointsAwarded: dto.pointsAwarded,
                state: OccurrenceState(apiValue: dto.state) ?? .available,
                deadline: dto.deadlineAt,
                occurrenceDate: dto.occurrenceDate,
                hasPhoto: dto.photoRequirement != "none"
            )
        }
    }
    
    func challenges() async throws -> [ChallengeSummary] {
        let response: ChallengesResponseDTO = try await client.get("challenges")
        
        return response.challenges.map { dto in
            ChallengeSummary(
                id: dto.id,
                name: dto.name,
                periodText: CalendarDayFormatter.periodText(from: dto.startDate, to: dto.endDate),
                state: ChallengeState(apiValue: dto.state) ?? .inProgress,
                currentDay: dto.currentDay,
                totalDays: dto.totalDays,
                myPoints: dto.myPoints,
                myRank: dto.myRank,
                participantsCount: dto.participantsCount,
                participantNames: dto.participants.map(\.name)
            )
        }
    }
    
    func completeTask(taskID: Int, occurrenceDate: String) async throws {
        let _: CompletionResponseDTO = try await client.post("completions", body: CompleteTaskRequest(taskId: taskID, occurrenceDate: occurrenceDate))
    }
}

private struct CompletionResponseDTO: Decodable {
    let id: Int
    let pointsAwarded: Int
}
