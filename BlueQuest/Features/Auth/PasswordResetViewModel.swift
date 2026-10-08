//
//  PasswordResetViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 08/10/26.
//

import Foundation

@MainActor
final class PasswordResetViewModel {
    enum Step {
        case email, code
    }
    
    private(set) var step: Step = .email
    private(set) var email: String
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var onChange: (() -> Void)?
    var onAuthenticated: (() -> Void)?
    
    init(email: String) {
        self.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func sendCode(to email: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard email.contains("@") else {
            show("Informe o e-mail da sua conta.")
            return
        }
        
        await run {
            try await AuthService.shared.requestPasswordReset(email: email)
            self.email = email
            self.step = .code
        }
    }
    
    func resendCode() async {
        await sendCode(to: email)
    }
    
    func reset(code: String, password: String, confirmation: String) async {
        let code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard code.count == 6, code.allSatisfy(\.isNumber) else {
            show("O código tem 6 números.")
            return
        }
        
        guard password.count >= 8 else {
            show("A nova senha precisa ter pelo menos 8 caracteres.")
            return
        }
        
        guard password == confirmation else {
            show("As senhas não conferem.")
            return
        }
        
        await run {
            let result = try await AuthService.shared.resetPassword(email: self.email, code: code, password: password, confirmation: confirmation)
            
            Session.shared.start(token: result.token, user: result.user)
            self.onAuthenticated?()
        }
    }
    
    func useAnotherEmail() {
        step = .email
        errorMessage = nil
        onChange?()
    }
    
    private func run(_ action: () async throws -> Void) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            try await action()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível continuar."
        }
    }
    
    private func show(_ message: String) {
        errorMessage = message
        onChange?()
    }
}
