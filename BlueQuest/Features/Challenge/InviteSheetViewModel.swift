//
//  InviteSheetViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation

@MainActor
final class InviteSheetViewModel {
    let challengeName: String
    
    private(set) var link: String?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var onChange: (() -> Void)?
    
    private let challengeID: Int
    
    init(challengeID: Int, challengeName: String) {
        self.challengeID = challengeID
        self.challengeName = challengeName
    }
    
    func load() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            link = try await ChallengeService.shared.inviteLink(challengeID: challengeID)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível gerar o link do convite."
        }
    }
}
