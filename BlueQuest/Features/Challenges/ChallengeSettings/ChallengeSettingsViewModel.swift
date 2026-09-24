//
//  ChallengeSettingsViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 11/09/26.
//

import Foundation

@MainActor
final class ChallengeSettingsViewModel {
    private(set) var isLoading = false
    private(set) var loadError: String?
    private(set) var savingOperation: ChallengeSettingsOperation?
    private(set) var saveError: String?
    private(set) var challengeName = ""
    private(set) var form: ChallengeSettingsForm?
    private(set) var tasks: [ChallengeSettingsTaskRow] = []
    private(set) var participants: [ChallengeParticipantRow] = []
    private(set) var invite: ChallengeInvite?
    
    var isSaving: Bool { savingOperation != nil }
    var onOperationError: ((String) -> Void)?
    var onChange: (() -> Void)?
    var onSaved: ((String) -> Void)?
    var onEnded: (() -> Void)?
    var onDeleted: (() -> Void)?
    
    private let challengeID: Int
    
    private var taskValues: [Int: TaskFormValues] = [:]
    private var pendingInviteEnabled: Bool?
    
    var removableParticipants: [ChallengeParticipantRow] {
        participants.filter { !$0.isCreator }
    }
    
    var isInviteEnabled: Bool {
        pendingInviteEnabled ?? invite?.isEnabled ?? false
    }
    
    var inviteSubtitle: String {
        let uses = invite?.uses ?? 0
        let usesText = uses == 1 ? "1 uso" : "\(uses) usos"
        return isInviteEnabled ? "Convite ativo · \(usesText)" : "Convite desativado · \(usesText)"
    }
    
    var taskDateRange: ClosedRange<Date>? {
        guard let form else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let lower = max(calendar.startOfDay(for: form.startDate), tomorrow)
        let upper = calendar.startOfDay(for: form.endDate)
        
        return lower <= upper ? lower...upper : nil
    }
    
    init(challengeID: Int) {
        self.challengeID = challengeID
    }
    
    func load(showingLoader: Bool = true) async {
        if showingLoader { isLoading = true }
        
        loadError = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            async let detail = ChallengeService.shared.challengeDetail(id: challengeID)
            async let invite = ChallengeService.shared.invite(challengeID: challengeID)
            
            apply(try await detail)
            self.invite = try await invite
        } catch {
            loadError = (error as? APIError)?.errorDescription ?? "Não foi possível carregar o desafio."
        }
    }
    
    func save(_ values: ChallengeSettingsValues) async {
        guard !isSaving else { return }
        
        if let message = validate(values) {
            saveError = message
            onChange?()
            return
        }
        
        savingOperation = .details
        saveError = nil
        onChange?()
        
        defer {
            savingOperation = nil
            onChange?()
        }
        
        let name = values.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try await ChallengeService.shared.updateChallenge(
                id: challengeID,
                ChallengeChanges(
                    name: name,
                    description: values.description.trimmingCharacters(in: .whitespacesAndNewlines),
                    startDate: CalendarDayFormatter.dayString(from: values.startDate),
                    endDate: CalendarDayFormatter.dayString(from: values.endDate)
                )
            )
            
            challengeName = name
            onSaved?("Alterações salvas")
        } catch {
            saveError = (error as? APIError)?.errorDescription ?? "Não foi possível salvar as alterações."
        }
    }
    
    func formValues(forTaskID id: Int) -> TaskFormValues? {
        taskValues[id]
    }
    
    func saveTask(_ values: TaskFormValues, taskID: Int?) async {
        let task = NewTask(from: values)
        
        await runOperation(
            .task,
            successMessage: taskID == nil ? "Tarefa adicionada" : "Tarefa atualizada",
            failureMessage: "Não foi possível salvar a tarefa."
        ) {
            if let taskID {
                try await ChallengeService.shared.updateTask(id: taskID, task)
            } else {
                try await ChallengeService.shared.createTask(challengeID: challengeID, task)
            }
        }
    }
    
    func deleteTask(id: Int) async {
        await runOperation(
            .task,
            successMessage: "Tarefa excluída",
            failureMessage: "Não foi possível excluir a tarefa."
        ) {
            try await ChallengeService.shared.deleteTask(id: id)
        }
    }
    
    func removeParticipant(userID: Int) async {
        await runOperation(
            .participant,
            successMessage: "Participante removido",
            failureMessage: "Não foi possível remover o participante."
        ) {
            try await ChallengeService.shared.removeParticipant(challengeID: challengeID, userID: userID)
        }
    }
    
    func setInviteEnabled(_ enabled: Bool) async {
        pendingInviteEnabled = enabled
        
        defer {
            pendingInviteEnabled = nil
            onChange?()
        }
        
        await runOperation(
            .invite,
            successMessage: enabled ? "Convite ativado" : "Convite desativado",
            failureMessage: "Não foi possível alterar o convite."
        ) {
            try await ChallengeService.shared.setInviteEnabled(challengeID: challengeID, enabled: enabled)
        }
    }
    
    func endChallenge() async {
        let ended = await runOperation(
            .challenge,
            successMessage: nil,
            failureMessage: "Não foi possível encerrar o desafio.",
            reloadsOnSuccess: false
        ) {
            try await ChallengeService.shared.endChallenge(id: challengeID)
        }
        
        if ended {
            onEnded?()
        }
    }
    
    func deleteChallenge() async {
        let deleted = await runOperation(
            .challenge,
            successMessage: nil,
            failureMessage: "Não foi possível excluir o desafio.",
            reloadsOnSuccess: false
        ) {
            try await ChallengeService.shared.deleteChallenge(id: challengeID)
        }
        
        if deleted {
            onDeleted?()
        }
    }
    
    @discardableResult
    private func runOperation(
        _ kind: ChallengeSettingsOperation,
        successMessage: String?,
        failureMessage: String,
        reloadsOnSuccess: Bool = true,
        _ operation: () async throws -> Void
    ) async -> Bool {
        guard !isSaving else { return false }
        
        savingOperation = kind
        onChange?()
        
        defer {
            savingOperation = nil
            onChange?()
        }
        
        do {
            try await operation()
            
            if reloadsOnSuccess {
                await load(showingLoader: false)
            }
            
            if let successMessage {
                onSaved?(successMessage)
            }
            
            return true
        } catch {
            onOperationError?((error as? APIError)?.errorDescription ?? failureMessage)
            return false
        }
    }
    
    private static func subtitle(for task: ChallengeDetailTask) -> String {
        let recurrence = task.recurrenceText.prefix(1).uppercased() + task.recurrenceText.dropFirst()
        
        var parts = [recurrence, "até \(task.deadlineText)", "+\(task.points) pts"]
        
        if task.hasPhoto {
            parts.append("com foto")
        }
        
        return parts.joined(separator: " · ")
    }
    
    private static func makeFormValues(for task: ChallengeDetailTask) -> TaskFormValues {
        TaskFormValues(
            name: task.name,
            points: task.points,
            mode: task.recurrenceType == "dates" ? .dates : .weekly,
            weekdays: task.recurrenceType == "daily" ? Set(1...7) : Set(task.weekdays),
            dates: task.dates,
            deadline: CalendarDayFormatter.localTime(from: task.deadlineTime) ?? Date(),
            requiresPhoto: task.hasPhoto
        )
    }
    
    private func validate(_ values: ChallengeSettingsValues) -> String? {
        if values.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Dê um nome ao desafio."
        }
        
        let calendar = Calendar.current
        if calendar.startOfDay(for: values.endDate) < calendar.startOfDay(for: values.startDate) {
            return "O término precisa ser no mesmo dia ou depois do início."
        }
        
        return nil
    }
    
    private func apply(_ detail: ChallengeDetail) {
        challengeName = detail.name
        
        form = ChallengeSettingsForm(
            name: detail.name,
            description: detail.description ?? "",
            startDate: CalendarDayFormatter.localDate(from: detail.startDate) ?? Date(),
            endDate: CalendarDayFormatter.localDate(from: detail.endDate) ?? Date(),
            canEditDetails: detail.state != .closed,
            canEditStart: detail.state == .future,
            canEnd: detail.state == .inProgress
        )
        
        tasks = detail.tasks.map {
            ChallengeSettingsTaskRow(id: $0.id, title: $0.name, subtitle: Self.subtitle(for: $0))
        }
        
        taskValues = Dictionary(uniqueKeysWithValues: detail.tasks.map { ($0.id, Self.makeFormValues(for: $0)) })
        
        participants = ChallengeParticipantRow.rows(from: detail.participants)
    }
}

struct ChallengeSettingsForm {
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let canEditDetails: Bool
    let canEditStart: Bool
    let canEnd: Bool
}

struct ChallengeSettingsValues {
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
}

struct ChallengeSettingsTaskRow {
    let id: Int
    let title: String
    let subtitle: String
}

enum ChallengeSettingsOperation {
    case details
    case task
    case participant
    case invite
    case challenge
}
