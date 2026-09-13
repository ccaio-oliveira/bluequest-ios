//
//  ChallengeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation

@MainActor
final class ChallengeViewModel {
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isCreator = false
    
    private(set) var header = ChallengeHeader(name: "", subtitle: "", day: 0, totalDays: 0, remainingText: "")
    private(set) var ranking: [ChallengeRankingRow] = []
    private(set) var participantRows: [ChallengeParticipantRow] = []
    private(set) var personalStats = ChallengePersonalStats(points: 0, position: 0, completedCount: 0, streakDays: 0, expiredCount: 0)
    private(set) var taskRows: [ChallengeTaskRow] = []
    
    var onChange: (() -> Void)?
    
    var hasContent: Bool { !ranking.isEmpty }
    
    private let challengeID: Int
    
    init(challengeID: Int) {
        self.challengeID = challengeID
    }
    
    func load(showingLoader: Bool = true) async {
        if showingLoader { isLoading = true }
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            let detail = try await ChallengeService.shared.challengeDetail(id: challengeID)
            apply(detail)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível carregar o desafio."
        }
    }
    
    private func apply(_ detail: ChallengeDetail) {
        let remaining = max(detail.totalDays - detail.currentDay, 0)
        isCreator = detail.isCreator
        
        header = ChallengeHeader(
            name: detail.name,
            subtitle: "\(detail.periodText) · \(detail.participantsCount) \(detail.participantsCount == 1 ? "participante" : "participantes")",
            day: detail.currentDay,
            totalDays: detail.totalDays,
            remainingText: detail.state == .closed ? "encerrado" : (remaining == 0 ? "último dia" : "termina em \(remaining) dias")
        )
        
        ranking = detail.participants.map {
            ChallengeRankingRow(position: $0.position, name: $0.name, points: $0.points, isYou: $0.isYou)
        }
        
        participantRows = detail.participants.map {
            ChallengeParticipantRow(
                name: $0.name,
                joinedText: $0.joinedText,
                points: $0.points,
                isCreator: $0.isCreator,
                isYou: $0.isYou
            )
        }
        .sorted { lhs, rhs in
            if lhs.isCreator != rhs.isCreator { return lhs.isCreator }
            return lhs.points > rhs.points
        }
        
        personalStats = ChallengePersonalStats(
            points: detail.stats.points,
            position: detail.stats.position,
            completedCount: detail.stats.completedCount,
            streakDays: detail.stats.streakDays,
            expiredCount: detail.stats.expiredCount
        )
        
        taskRows = detail.tasks.map {
            ChallengeTaskRow(
                card: TaskCardModel(
                    taskName: $0.name,
                    points: $0.points,
                    state: .available,
                    deadlineText: $0.deadlineText,
                    hasPhoto: $0.hasPhoto
                ),
                recurrenceText: "\($0.name.lowercased()) \($0.recurrenceText)"
            )
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
