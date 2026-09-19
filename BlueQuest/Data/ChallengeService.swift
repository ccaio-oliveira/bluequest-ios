//
//  ChallengeService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation

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
    
    func challengeDetail(id: Int) async throws -> ChallengeDetail {
        let dto: ChallengeDetailDTO = try await client.get("challenges/\(id)")
        
        return ChallengeDetail(
            name: dto.name,
            description: dto.description,
            startDate: dto.startDate,
            endDate: dto.endDate,
            isCreator: dto.ranking.contains { $0.isYou && $0.isCreator },
            periodText: CalendarDayFormatter.periodText(from: dto.startDate, to: dto.endDate),
            state: ChallengeState(apiValue: dto.state) ?? .inProgress,
            currentDay: dto.currentDay,
            totalDays: dto.totalDays,
            participantsCount: dto.participantsCount,
            participants: dto.ranking.map { participant in
                ChallengeDetailParticipant(
                    userID: participant.userId,
                    name: participant.name,
                    points: participant.points,
                    position: participant.position,
                    joinedText: CalendarDayFormatter.dayMonthText(from: participant.joinedAt),
                    isCreator: participant.isCreator,
                    isYou: participant.isYou
                )
            },
            stats: ChallengeDetailStats(
                points: dto.me.points,
                position: dto.me.position ?? 0,
                completedCount: dto.me.completedCount,
                expiredCount: dto.me.expiredCount,
                totalOccurrences: dto.me.totalOccurrences,
                streakDays: dto.me.streakDays
            ),
            tasks: dto.tasks.map { task in
                ChallengeDetailTask(
                    id: task.id,
                    name: task.name,
                    points: task.points,
                    deadlineTime: task.deadlineTime,
                    deadlineText: CalendarDayFormatter.timeText(from: task.deadlineTime),
                    hasPhoto: task.photoRequirement != "none",
                    recurrenceType: task.recurrenceType,
                    weekdays: task.recurrenceWeekdays ?? [],
                    recurrenceText: Self.recurrenceText(
                        type: task.recurrenceType,
                        weekdays: task.recurrenceWeekdays
                    )
                )
            }
        )
    }
    
    func completeTask(taskID: Int, occurrenceDate: String, photoURL: String? = nil) async throws {
        let _: CompletionResponseDTO = try await client.post("completions", body: CompleteTaskRequest(taskId: taskID, occurrenceDate: occurrenceDate, photoUrl: photoURL))
    }
    
    func create(_ challenge: NewChallenge) async throws {
        let body = CreateChallengeRequest(
            name: challenge.name,
            description: challenge.description,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
            timezone: challenge.timezone,
            tasks: challenge.tasks.map { task in
                Self.body(for: task)
            }
        )
        
        let _: ChallengeSummaryDTO = try await client.post("challenges", body: body)
    }
    
    func updateChallenge(id: Int, _ changes: ChallengeChanges) async throws {
        let body = UpdateChallengeRequest(
            name: changes.name,
            description: changes.description,
            startDate: changes.startDate,
            endDate: changes.endDate
        )
        
        try await client.put("challenges/\(id)", body: body)
    }
    
    func invite(challengeID: Int) async throws -> ChallengeInvite {
        let dto: InviteDTO = try await client.get("challenges/\(challengeID)/invite")
        return ChallengeInvite(isEnabled: dto.enabled, link: dto.link, uses: dto.uses)
    }
    
    func setInviteEnabled(challengeID: Int, enabled: Bool) async throws {
        try await client.put("challenges/\(challengeID)/invite", body: InviteToggleRequest(enabled: enabled))
    }
    
    func invitePreview(code: String) async throws -> InvitePreview {
        let dto: InvitePreviewDTO = try await client.get("invites/\(code)")
        let challenge = dto.challenge
        
        return InvitePreview(
            state: InviteState(rawValue: dto.state) ?? .invalid,
            challengeID: challenge?.id,
            name: challenge?.name ?? "",
            periodText: challenge.map {
                CalendarDayFormatter.periodText(from: $0.startDate, to: $0.endDate)
            } ?? "",
            invitedBy: challenge?.invitedBy,
            participantNames: challenge?.participants.map(\.name) ?? [],
            participantsCount: challenge?.participantsCount ?? 0,
            totalDays: challenge?.totalDays ?? 0,
            tasksCount: challenge?.tasksCount ?? 0,
            maxPointsPerDay: challenge?.maxPointsPerDay ?? 0
        )
    }
    
    func acceptInvite(code: String) async throws -> Int {
        let dto: AcceptInviteDTO = try await client.post("invites/\(code)/accept", body: EmptyBody())
        return dto.challengeId
    }
    
    func createTask(challengeID: Int, _ task: NewTask) async throws {
        let _: TaskCreatedDTO = try await client.post("challenges/\(challengeID)/tasks", body: Self.body(for: task))
    }
    
    func updateTask(id: Int, _ task: NewTask) async throws {
        try await client.put("tasks/\(id)", body: Self.body(for: task))
    }
    
    func deleteTask(id: Int) async throws {
        try await client.delete("tasks/\(id)")
    }
    
    func removeParticipant(challengeID: Int, userID: Int) async throws {
        try await client.delete("challenges/\(challengeID)/participants/\(userID)")
    }
    
    func endChallenge(id: Int) async throws {
        try await client.postWithoutResponse("challenges/\(id)/end")
    }
    
    func deleteChallenge(id: Int) async throws {
        try await client.delete("challenges/\(id)")
    }
    
    private static func recurrenceText(type: String, weekdays: [Int]?) -> String {
        switch type {
        case "daily":
            return "todos os dias"
        case "once":
            return "uma vez"
        default:
            let names = [1: "dom", 2: "seg", 3: "ter", 4: "qua", 5: "qui", 6: "sex", 7: "sáb"]
            return (weekdays ?? []).sorted().compactMap { names[$0] }.joined(separator: "/")
        }
    }
    
    private static func body(for task: NewTask) -> CreateTaskRequest {
        CreateTaskRequest(
            name: task.name,
            points: task.points,
            recurrenceType: task.recurrenceType,
            recurrenceWeekdays: task.weekdays,
            deadlineTime: task.deadlineTime,
            photoRequirement: task.photoRequirement
        )
    }
}

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

private struct ChallengeDetailDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let startDate: String
    let endDate: String
    let state: String
    let currentDay: Int
    let totalDays: Int
    let creatorUserId: Int
    let participantsCount: Int
    let ranking: [DetailParticipantDTO]
    let me: DetailStatsDTO
    let tasks: [DetailTaskDTO]
}

private struct ParticipantSummaryDTO: Decodable {
    let name: String
}

private struct DetailParticipantDTO: Decodable {
    let userId: Int
    let name: String
    let points: Int
    let position: Int
    let joinedAt: String
    let isCreator: Bool
    let isYou: Bool
}

private struct DetailStatsDTO: Decodable {
    let completedCount: Int
    let expiredCount: Int
    let totalOccurrences: Int
    let streakDays: Int
    let points: Int
    let position: Int?
}

private struct CompleteTaskRequest: Encodable {
    let taskId: Int
    let occurrenceDate: String
    let photoUrl: String?
}

private struct CreateTaskRequest: Encodable {
    let name: String
    let points: Int
    let recurrenceType: String
    let recurrenceWeekdays: [Int]?
    let deadlineTime: String
    let photoRequirement: String
}

private struct DetailTaskDTO: Decodable {
    let id: Int
    let name: String
    let points: Int
    let deadlineTime: String
    let photoRequirement: String
    let recurrenceType: String
    let recurrenceWeekdays: [Int]?
}

private struct CreateChallengeRequest: Encodable {
    let name: String
    let description: String?
    let startDate: String
    let endDate: String
    let timezone: String
    let tasks: [CreateTaskRequest]
}

private struct CompletionResponseDTO: Decodable {
    let id: Int
    let pointsAwarded: Int
}

private struct InviteDTO: Decodable {
    let enabled: Bool
    let link: String?
    let uses: Int
}

private struct InviteToggleRequest: Encodable {
    let enabled: Bool
}

private struct InvitePreviewDTO: Decodable {
    let state: String
    let challenge: InviteChallengeDTO?
}

private struct InviteChallengeDTO: Decodable {
    let id: Int
    let name: String
    let startDate: String
    let endDate: String
    let totalDays: Int
    let participantsCount: Int
    let participants: [ParticipantSummaryDTO]
    let invitedBy: String?
    let tasksCount: Int
    let maxPointsPerDay: Int
}

private struct AcceptInviteDTO: Decodable {
    let challengeId: Int
}

private struct UpdateChallengeRequest: Encodable {
    let name: String
    let description: String
    let startDate: String
    let endDate: String
}

private struct TaskCreatedDTO: Decodable {
    let id: Int
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

struct NewChallenge {
    let name: String
    let description: String?
    let startDate: String
    let endDate: String
    let timezone: String
    let tasks: [NewTask]
}

struct NewTask {
    let name: String
    let points: Int
    let recurrenceType: String
    let weekdays: [Int]?
    let deadlineTime: String
    let photoRequirement: String
}

struct ChallengeDetailParticipant {
    let userID: Int
    let name: String
    let points: Int
    let position: Int
    let joinedText: String
    let isCreator: Bool
    let isYou: Bool
}

struct ChallengeDetailTask {
    let id: Int
    let name: String
    let points: Int
    let deadlineTime: String
    let deadlineText: String
    let hasPhoto: Bool
    let recurrenceType: String
    let weekdays: [Int]
    let recurrenceText: String
}

struct ChallengeDetailStats {
    let points: Int
    let position: Int
    let completedCount: Int
    let expiredCount: Int
    let totalOccurrences: Int
    let streakDays: Int
}

struct ChallengeDetail {
    let name: String
    let description: String?
    let startDate: String
    let endDate: String
    let isCreator: Bool
    let periodText: String
    let state: ChallengeState
    let currentDay: Int
    let totalDays: Int
    let participantsCount: Int
    let participants: [ChallengeDetailParticipant]
    let stats: ChallengeDetailStats
    let tasks: [ChallengeDetailTask]
}

struct InvitePreview {
    let state: InviteState
    let challengeID: Int?
    let name: String
    let periodText: String
    let invitedBy: String?
    let participantNames: [String]
    let participantsCount: Int
    let totalDays: Int
    let tasksCount: Int
    let maxPointsPerDay: Int
}

struct ChallengeChanges {
    let name: String
    let description: String
    let startDate: String
    let endDate: String
}

struct ChallengeInvite {
    let isEnabled: Bool
    let link: String?
    let uses: Int
}
