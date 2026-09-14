//
//  ChallengeSettingsViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 11/09/26.
//

import Foundation

struct ChallengeSettingsForm {
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let canEditDetails: Bool
    let canEditStart: Bool
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

@MainActor
final class ChallengeSettingsViewModel {
    private(set) var isLoading = false
    private(set) var loadError: String?
    private(set) var isSaving = false
    private(set) var saveError: String?
    private(set) var challengeName = ""
    private(set) var form: ChallengeSettingsForm?
    private(set) var tasks: [ChallengeSettingsTaskRow] = []
    
    private var taskValues: [Int: TaskFormValues] = [:]
    
    var onChange: (() -> Void)?
    var onSaved: ((String) -> Void)?
    
    private let challengeID: Int
    
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
            let detail = try await ChallengeService.shared.challengeDetail(id: challengeID)
            apply(detail)
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
        
        isSaving = true
        saveError = nil
        onChange?()
        
        defer {
            isSaving = false
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
        guard !isSaving else { return }
        
        isSaving = true
        saveError = nil
        onChange?()
        
        defer {
            isSaving = false
            onChange?()
        }
        
        let isEveryDay = values.weekdays.count == 7
        
        let task = NewTask(
            name: values.name,
            points: values.points,
            recurrenceType: isEveryDay ? "daily" : "weekdays",
            weekdays: isEveryDay ? nil : values.weekdays.sorted(),
            deadlineTime: CalendarDayFormatter.timeString(from: values.deadline),
            photoRequirement: values.allowsPhoto ? "optional" : "none"
        )
        
        do {
            if let taskID {
                try await ChallengeService.shared.updateTask(id: taskID, task)
            } else {
                try await ChallengeService.shared.createTask(challengeID: challengeID, task)
            }
            
            await load(showingLoader: false)
            onSaved?(taskID == nil ? "Tarefa adicionada" : "Tarefa atualizada")
        } catch {
            saveError = (error as? APIError)?.errorDescription ?? "Não foi possível salvar a tarefa."
        }
    }
    
    func deleteTask(id: Int) async {
        guard !isSaving else { return }
        
        isSaving = true
        saveError = nil
        onChange?()
        
        defer {
            isSaving = false
            onChange?()
        }
        
        do {
            try await ChallengeService.shared.deleteTask(id: id)
            await load(showingLoader: false)
            onSaved?("Tarefa excluída")
        } catch {
            saveError = (error as? APIError)?.errorDescription ?? "Não foi possível excluir a tarefa."
        }
    }
    
    private static func subtitle(for task: ChallengeDetailTask) -> String {
        let recurrence = task.recurrenceText.prefix(1).uppercased() + task.recurrenceText.dropFirst()
        
        var parts = [recurrence, "até \(task.deadlineText)", "+\(task.points) pts"]
        
        if task.hasPhoto {
            parts.append("foto opcional")
        }
        
        return parts.joined(separator: " · ")
    }
    
    private static func makeFormValues(for task: ChallengeDetailTask) -> TaskFormValues {
        TaskFormValues(
            name: task.name,
            points: task.points,
            weekdays: task.recurrenceType == "daily" ? Set(1...7) : Set(task.weekdays),
            deadline: CalendarDayFormatter.localTime(from: task.deadlineTime) ?? Date(),
            allowsPhoto: task.hasPhoto
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
            canEditStart: detail.state == .future
        )
        
        tasks = detail.tasks.map {
            ChallengeSettingsTaskRow(id: $0.id, title: $0.name, subtitle: Self.subtitle(for: $0))
        }
        
        taskValues = Dictionary(uniqueKeysWithValues: detail.tasks.map { ($0.id, Self.makeFormValues(for: $0)) })
    }
}
