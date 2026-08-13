//
//  HomeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation

@MainActor
final class HomeViewModel {
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var rows: [HomeTaskRow] = []
    private(set) var challenges: [HomeChallengeRow] = []
    private(set) var header = HomeHeader(dateText: "", points: 0, completedCount: 0, doableCount: 0)
    
    var onChange: (() -> Void)?
    var onPointsAwarded: ((Int) -> Void)?
    var onActionError: ((String) -> Void)?
    
    private var occurrences: [TodayOccurrence] = []
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d MMM"
        return formatter
    }()

    var hasContent: Bool {
        !rows.isEmpty || !challenges.isEmpty
    }
    
    enum HomeEmptyState {
        case none
        case noChallenges
        case noTasksToday
    }

    var emptyState: HomeEmptyState {
        if challenges.isEmpty { return .noChallenges }
        if rows.isEmpty { return .noTasksToday }
        return .none
    }
    
    func logout() async {
        try? await AuthService.shared.logout()
        Session.shared.end()
    }
    
    func load(showingLoader: Bool = true) async {
        if showingLoader {
            isLoading = true
        }
        
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            async let todayRequest = ChallengeService.shared.today()
            async let challengesRequest = ChallengeService.shared.challenges()
            
            let (today, summaries) = try await (todayRequest, challengesRequest)
            
            occurrences = today
            
            rebuildRows()
            rebuildHeader()
            rebuildChallenges(from: summaries)
        } catch {
            isLoading = false
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível carregar seus desafios."
            onChange?()
        }
    }
    
    func completeTask(taskID: Int) async {
        guard let occurrence = occurrences.first(where: { $0.taskID == taskID }), occurrence.state == .available else { return }
        
        do {
            try await ChallengeService.shared.completeTask(taskID: taskID, occurrenceDate: occurrence.occurrenceDate)
            
            onPointsAwarded?(occurrence.points)
            await load(showingLoader: false)
        } catch {
            onActionError?(
                (error as? APIError)?.errorDescription ?? "Não foi possível concluir a tarefa."
            )
            
            await load(showingLoader: false)
        }
    }
    
    private func rebuildRows() {
        rows = occurrences.map { occurrence in
            HomeTaskRow(
                taskID: occurrence.taskID,
                card: TaskCardModel(
                    taskName: occurrence.name,
                    points: occurrence.points,
                    state: occurrence.state,
                    deadlineText: timeFormatter.string(from: occurrence.deadline),
                    hasPhoto: occurrence.hasPhoto
                )
            )
        }
    }
    
    private func rebuildHeader() {
        let raw = dayFormatter.string(from: Date())
            .replacingOccurrences(of: "-feira", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        let weekday = raw.prefix(1).uppercased() + raw.dropFirst()
        
        header = HomeHeader(
            dateText: "Hoje · \(weekday)",
            points: occurrences.compactMap(\.pointsAwarded).reduce(0, +),
            completedCount: occurrences.filter { $0.state == .completed }.count,
            doableCount: occurrences.filter { $0.state != .future }.count
        )
    }
    
    private func rebuildChallenges(from summaries: [ChallengeSummary]) {
        challenges = summaries.enumerated().map { index, summary in
            HomeChallengeRow(
                id: summary.id,
                name: summary.name,
                periodText: summary.periodText,
                day: summary.currentDay,
                totalDays: summary.totalDays,
                points: summary.myPoints,
                rank: summary.myRank,
                participantNames: summary.participantNames,
                state: summary.state,
                isHero: index == 0
            )
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
