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

@MainActor
final class ChallengeSettingsViewModel {
    private(set) var isLoading = false
    private(set) var loadError: String?
    private(set) var isSaving = false
    private(set) var saveError: String?
    private(set) var challengeName = ""
    private(set) var form: ChallengeSettingsForm?
    
    var onChange: (() -> Void)?
    var onSaved: (() -> Void)?
    
    private let challengeID: Int
    
    init(challengeID: Int) {
        self.challengeID = challengeID
    }
    
    func load() async {
        isLoading = true
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
            onSaved?()
        } catch {
            saveError = (error as? APIError)?.errorDescription ?? "Não foi possível salvar as alterações."
        }
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
    }
}
