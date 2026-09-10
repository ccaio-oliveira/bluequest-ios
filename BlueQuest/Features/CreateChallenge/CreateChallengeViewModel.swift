//
//  CreateChallengeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/08/26.
//

import Foundation

struct ChallengeFormValues {
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let tasks: [TaskFormValues]
}

@MainActor
final class CreateChallengeViewModel {
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    
    var onChange: (() -> Void)?
    var onCreated: (() -> Void)?
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func save(_ form: ChallengeFormValues) async {
        guard !isSaving else { return }
        
        if let problem = validate(form) {
            errorMessage = problem
            onChange?()
            return
        }
        
        isSaving = true
        errorMessage = nil
        onChange?()
        
        defer {
            isSaving = false
            onChange?()
        }
        
        do {
            try await ChallengeService.shared.create(payload(from: form))
            onCreated?()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível criar o desafio"
        }
    }
    
    private func validate(_ form: ChallengeFormValues) -> String? {
        if form.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Dê um nome ao desafio"
        }
        
        let calendar = Calendar.current
        if calendar.startOfDay(for: form.endDate) < calendar.startOfDay(for: form.startDate) {
            return "O término precisa ser no mesmo dia ou depois do início."
        }
        
        if form.tasks.isEmpty {
            return "Adicione pelo menos uma tarefa."
        }
        
        for (index, task) in form.tasks.enumerated() {
            let position = index + 1
            
            if task.name.isEmpty {
                return "Dê um nome à tarefa \(position)."
            }
            
            if task.points < 1 {
                return "A tarefa \(position) precisa valer pelo menos 1 ponto."
            }
            
            if task.weekdays.isEmpty {
                return "Escolha pelo menos um dia para a tarefa \(position)."
            }
        }
        
        return nil
    }
    
    private func payload(from form: ChallengeFormValues) -> NewChallenge {
        let description = form.description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return NewChallenge(
            name: form.name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description,
            startDate: Self.dayFormatter.string(from: form.startDate),
            endDate: Self.dayFormatter.string(from: form.endDate),
            timezone: TimeZone.current.identifier,
            tasks: form.tasks.map { task in
                let isEveryDay = task.weekdays.count == 7
                
                return NewTask(
                    name: task.name,
                    points: task.points,
                    recurrenceType: isEveryDay ? "daily" : "weekdays",
                    weekdays: isEveryDay ? nil : task.weekdays.sorted(),
                    deadlineTime: Self.timeFormatter.string(from: task.deadline),
                    photoRequirement: task.allowsPhoto ? "optional" : "none"
                )
            }
        )
    }
}
