//
//  ChallengeCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class ChallengeCoordinator: Coordinator {
    let navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    private let challengeID: Int
    
    init(navigationController: UINavigationController, challengeID: Int) {
        self.navigationController = navigationController
        self.challengeID = challengeID
    }
    
    func start() {
        let viewModel = ChallengeViewModel(challengeID: challengeID)
        let viewController = ChallengeViewController(viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        viewController.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        viewController.onInvite = { [weak self] in
            self?.showInviteSheet()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showInviteSheet() {
        let sheet = InviteSheetViewController(inviteURL: "bluequest.app/c/verao-x7k2")
        navigationController.present(sheet, animated: true)
    }
}
