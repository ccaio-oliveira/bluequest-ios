//
//  ChallengeResultViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 16/09/26.
//

import Foundation

@MainActor
final class ChallengeResultViewModel {
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var title = ""
    private(set) var subtitle = ""
    private(set) var podium: [PodiumEntry] = []
    private(set) var rows: [ChallengeRankingRow] = []
    private(set) var stats: ChallengeResultStats?
    
    var onChange: (() -> Void)?
    
    private let challengeID: Int
    
    init(challengeID: Int) {
        self.challengeID = challengeID
    }
    
    func load() async {
        isLoading = true
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
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível carregar o resultado."
        }
    }
    
    private func apply(_ detail: ChallengeDetail) {
        title = detail.name
        subtitle = "\(detail.periodText) · resultado final"
        
        let ranked = detail.participants.sorted { lhs, rhs in
            if lhs.position != rhs.position { return lhs.position < rhs.position }
            return lhs.name < rhs.name
        }
        
        podium = ranked.prefix(3).map {
            PodiumEntry(name: $0.name, points: $0.points, position: $0.position)
        }
        
        rows = ranked.enumerated()
            .filter { $0.offset >= 3 || $0.element.isYou }
            .map {
                ChallengeRankingRow(
                    position: $0.element.position,
                    name: $0.element.name,
                    points: $0.element.points,
                    isYou: $0.element.isYou
                )
            }
        
        stats = ChallengeResultStats(
            points: detail.stats.points,
            completedCount: detail.stats.completedCount,
            expiredCount: detail.stats.expiredCount
        )
    }
}

struct PodiumEntry: Equatable {
    let name: String
    let points: Int
    let position: Int
}

struct ChallengeResultStats: Equatable {
    let points: Int
    let completedCount: Int
    let expiredCount: Int
}
