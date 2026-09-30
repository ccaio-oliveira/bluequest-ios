//
//  NotificationPreferencesViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation
import UserNotifications

struct NotificationPreferenceRow {
    let keyPath: WritableKeyPath<NotificationPreferences, Bool>
    let icon: String
    let title: String
    let subtitle: String
}

struct PermissionBanner {
    let text: String
    let actionTitle: String
}

@MainActor
final class NotificationPreferencesViewModel {
    static let deviceRows = [
        NotificationPreferenceRow(
            keyPath: \.dailyReminder,
            icon: "checkmark.circle",
            title: "Lembrete do dia",
            subtitle: "Resumo das tarefas de manhã"
        ),
        NotificationPreferenceRow(
            keyPath: \.deadline,
            icon: "clock",
            title: "Proximidade do prazo",
            subtitle: "1h antes de uma tarefa expirar"
        ),
        NotificationPreferenceRow(
            keyPath: \.weeklyMandatory,
            icon: "exclamationmark.triangle",
            title: "Tarefas semanais",
            subtitle: "Quando uma tarefa por semana vira obrigatória"
        )
    ]
    
    static let activityRows = [
        NotificationPreferenceRow(
            keyPath: \.joined,
            icon: "person.badge.plus",
            title: "Novos participantes",
            subtitle: "Quando alguém entra no seu desafio"
        ),
        NotificationPreferenceRow(
            keyPath: \.ranking,
            icon: "trophy",
            title: "Ranking",
            subtitle: "Quando alguém passa você"
        ),
        NotificationPreferenceRow(
            keyPath: \.ended,
            icon: "flag",
            title: "Encerramento",
            subtitle: "Resultado final dos seus desafios"
        )
    ]
    
    private(set) var preferences: NotificationPreferences?
    private(set) var isLoading = false
    private(set) var loadError: String?
    private(set) var permissionStatus: UNAuthorizationStatus = .authorized
    
    var onChange: (() -> Void)?
    var onSaveError: ((String) -> Void)?
    
    var permissionBanner: PermissionBanner? {
        switch permissionStatus {
        case .notDetermined:
            PermissionBanner(text: "Ative as notificações para receber os lembretes neste iPhone.", actionTitle: "Ativar")
        case .denied:
            PermissionBanner(text: "As notificações do BlueQuest estão desligadas nos Ajustes do iPhone.", actionTitle: "Abrir Ajustes")
        default:
            nil
        }
    }
    
    func load() async {
        isLoading = true
        loadError = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        async let status = NotificationPermission.status()
        
        do {
            preferences = try await NotificationService.shared.preferences()
        } catch {
            loadError = (error as? APIError)?.errorDescription ?? "Não foi possível carregar suas preferências."
        }
        
        permissionStatus = await status
    }
    
    func refreshPermission() async {
        permissionStatus = await NotificationPermission.status()
        onChange?()
    }
    
    func requestPermission() async {
        await NotificationPermission.request()
        await refreshPermission()
    }
    
    func set(_ keyPath: WritableKeyPath<NotificationPreferences, Bool>, to value: Bool) async {
        guard var updated = preferences else { return }
        
        updated[keyPath: keyPath] = value
        preferences = updated
        onChange?()
        
        do {
            try await NotificationService.shared.updatePreferences(updated)
        } catch {
            preferences?[keyPath: keyPath] = !value
            onChange?()
            onSaveError?("Não foi possível salvar a preferência.")
        }
    }
}
