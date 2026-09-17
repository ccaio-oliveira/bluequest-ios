//
//  InviteViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

@MainActor
final class InviteViewModel {
    private(set) var preview: InvitePreview?
    private(set) var isLoading = false
    private(set) var isAccepting = false
    private(set) var errorMessage: String?
    
    var onChange: (() -> Void)?
    var onAccepted: ((Int) -> Void)?
    
    private let code: String
    
    init(code: String) {
        self.code = code
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            preview = try await ChallengeService.shared.invitePreview(code: code)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível abrir o convite"
        }
    }
    
    func accept() async {
        guard !isAccepting else { return }
        
        isAccepting = true
        errorMessage = nil
        onChange?()
        
        defer {
            isAccepting = false
            onChange?()
        }
        
        do {
            let challengeID = try await ChallengeService.shared.acceptInvite(code: code)
            onAccepted?(challengeID)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível entrar no desafio."
            await load()
        }
    }
}
