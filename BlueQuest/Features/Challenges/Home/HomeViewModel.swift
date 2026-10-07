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
    private(set) var allChallenges: [HomeChallengeRow] = []
    private(set) var filter: ChallengeFilter = .inProgress
    private(set) var header = HomeHeader(dateText: "", points: 0, completedCount: 0, doableCount: 0, unreadNotifications: 0)
    
    var onChange: (() -> Void)?
    var onPointsAwarded: ((Int) -> Void)?
    var onActionError: ((String) -> Void)?
    
    private var occurrences: [TodayOccurrence] = []
    private var unreadNotifications = 0
    private var queueObserver: NSObjectProtocol?
    
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
    
    var challenges: [HomeChallengeRow] {
        allChallenges.filter { $0.state == filter.state }
    }

    var hasContent: Bool {
        !rows.isEmpty || !allChallenges.isEmpty
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
    
    init() {
        queueObserver = NotificationCenter.default.addObserver(
            forName: .completionQueueDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let event = notification.userInfo?["event"] as? CompletionQueueEvent
            
            MainActor.assumeIsolated {
                self?.handleQueueChange(event)
            }
        }
    }
    
    deinit {
        if let queueObserver {
            NotificationCenter.default.removeObserver(queueObserver)
        }
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
            async let unreadRequest = NotificationService.shared.unreadCount()
            
            let (today, summaries) = try await (todayRequest, challengesRequest)
            unreadNotifications = (try? await unreadRequest) ?? 0
            
            occurrences = today
            
            rebuildRows()
            rebuildHeader()
            rebuildChallenges(from: summaries)
            Task { await ReminderScheduler.sync() }
        } catch {
            isLoading = false
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível carregar seus desafios."
            onChange?()
        }
    }
    
    func completeTask(taskID: Int, photo: Data? = nil) {
        guard let occurrence = occurrences.first(where: { $0.taskID == taskID }), occurrence.state == .available else { return }
        
        do {
            try CompletionQueue.shared.submit(
                taskID: taskID,
                taskName: occurrence.name,
                points: occurrence.points,
                occurrenceDate: occurrence.occurrenceDate,
                photo: photo
            )
        } catch {
            onActionError?("Não foi possível guardar a foto no aparelho.")
        }
    }
    
    func setFilter(_ filter: ChallengeFilter) {
        self.filter = filter
        onChange?()
    }
    
    private func rebuildRows() {
        rows = occurrences.map { occurrence in
            HomeTaskRow(
                taskID: occurrence.taskID,
                challengeName: occurrence.challengeName,
                card: TaskCardModel(
                    taskName: occurrence.name,
                    points: occurrence.points,
                    state: occurrence.state,
                    deadlineText: timeFormatter.string(from: occurrence.deadline),
                    hasPhoto: occurrence.hasPhoto,
                    weekly: occurrence.weekly,
                    isSending: CompletionQueue.shared.isPending(taskID: occurrence.taskID, occurrenceDate: occurrence.occurrenceDate)
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
            doableCount: occurrences.filter { $0.state != .future && !$0.isOptional }.count,
            unreadNotifications: unreadNotifications
        )
    }
    
    private func rebuildChallenges(from summaries: [ChallengeSummary]) {
        var heroAssigned = false
        
        allChallenges = summaries.map { summary in
            let isHero = !heroAssigned && summary.state == .inProgress
            
            if isHero { heroAssigned = true }
            
            return HomeChallengeRow(
                id: summary.id,
                name: summary.name,
                periodText: summary.periodText,
                day: summary.currentDay,
                totalDays: summary.totalDays,
                points: summary.myPoints,
                rank: summary.myRank,
                participantNames: summary.participantNames,
                participantsCount: summary.participantsCount,
                state: summary.state,
                isHero: isHero
            )
        }
    }
    
    private func handleQueueChange(_ event: CompletionQueueEvent?) {
        switch event {
        case .sent(let item):
            onPointsAwarded?(item.points)
            Task { await load(showingLoader: false) }
        case .rejected(let item, let message):
            onActionError?("\(item.taskName): \(message)")
            Task { await load(showingLoader: false) }
        case nil:
            rebuildRows()
            onChange?()
        }
    }
}

struct HomeTaskRow: Equatable {
    let taskID: Int
    let challengeName: String
    let card: TaskCardModel
}

struct HomeHeader: Equatable {
    let dateText: String
    let points: Int
    let completedCount: Int
    let doableCount: Int
    let unreadNotifications: Int
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
    let participantsCount: Int
    let state: ChallengeState
    let isHero: Bool
}

enum ChallengeFilter: Int, CaseIterable {
    case inProgress, future, closed
    
    var title: String {
        switch self {
        case .inProgress: "Em andamento"
        case .future: "Futuros"
        case .closed: "Encerrados"
        }
    }
    
    var state: ChallengeState {
        switch self {
        case .inProgress: .inProgress
        case .future: .future
        case .closed: .closed
        }
    }
}
