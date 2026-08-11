//
//  AuthViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation

@MainActor
final class AuthViewModel {
    enum Mode: Int {
        case signIn = 0
        case signUp = 1
        
        var actionTitle: String {
            switch self {
            case .signIn: "Entrar"
            case .signUp: "Criar conta"
            }
        }
    }
    
    private(set) var mode: Mode = .signIn
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var onChange: (() -> Void)?
    var onAuthenticated: (() -> Void)?
    
    func setMode(_ mode: Mode) {
        self.mode = mode
        errorMessage = nil
        onChange?()
    }
    
    func submit(name: String, email: String, password: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        onChange?()
        
        do {
            let result: (user: User, token: String)
            
            switch mode {
            case .signIn:
                result = try await AuthService.shared.login(email: email, password: password)
            case .signUp:
                result = try await AuthService.shared.register(name: name, email: email, password: password)
            }
            
            Session.shared.start(token: result.token, user: result.user)
            isLoading = false
            onChange?()
            onAuthenticated?()
        } catch {
            isLoading = false
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível continuar."
            onChange?()
        }
    }
}
