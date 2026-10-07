//
//  AccountViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/10/26.
//

import Foundation

@MainActor
final class AccountViewModel {
    enum Operation {
        case details, password
    }
    
    private(set) var user: User?
    private(set) var savingOperation: Operation?
    
    var onChange: (() -> Void)?
    var onSaved: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    var hasPassword: Bool {
        user?.hasPassword ?? false
    }
    
    init () {
        user = Session.shared.currentUser
    }
    
    func emailChanged(_ email: String) -> Bool {
        guard let user else { return false }
        
        return Self.normalized(email) != Self.normalized(user.email)
    }
    
    func saveDetails(name: String, email: String, currentPassword: String) async -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty {
            onError?("Informe seu nome.")
            return false
        }
        
        if emailChanged(email) && currentPassword.isEmpty {
            onError?("Digite sua senha atual para trocar o e-mail.")
            return false
        }
        
        return await run(.details, successMessage: "Dados atualizados") {
            try await ProfileService.shared.updateAccount(name: name, email: email, currentPassword: currentPassword.isEmpty ? nil : currentPassword)
        }
    }
    
    func savePassword(current: String, new: String, confirmation: String) async -> Bool {
        let isCreating = !hasPassword
        
        if !isCreating && current.isEmpty {
            onError?("Digite sua senha atual.")
            return false
        }
        
        if new.count < 8 {
            onError?("A nova senha precisa ter pelo menos 8 caracteres.")
            return false
        }
        
        if new != confirmation {
            onError?("As senhas não conferem.")
            return false
        }
        
        return await run(.password, successMessage: isCreating ? "Senha criada" : "Senha alterada") {
            try await ProfileService.shared.updatePassword(current: isCreating ? nil : current, new: new, confirmation: confirmation)
        }
    }
    
    private func run(_ operation: Operation, successMessage: String, _ request: () async throws -> User) async -> Bool {
        guard savingOperation == nil else { return false }
        
        savingOperation = operation
        onChange?()
        
        defer {
            savingOperation = nil
            onChange?()
        }
        
        do {
            let updated = try await request()
            user = updated
            Session.shared.update(user: updated)
            onSaved?(successMessage)
            return true
        } catch {
            onError?((error as? APIError)?.errorDescription ?? "Não foi possível salvar.")
            return false
        }
    }
    
    private static func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
