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
    private let destination: Destination
    
    enum Destination {
        case detail
        case result
    }
    
    init(navigationController: UINavigationController, challengeID: Int, destination: Destination = .detail) {
        self.navigationController = navigationController
        self.challengeID = challengeID
        self.destination = destination
    }
    
    func start() {
        switch destination {
        case .detail:
            showDetail()
        case .result:
            navigationController.pushViewController(makeResult(), animated: true)
        }
    }
    
    private func showInviteSheet(challengeName: String) {
        let viewModel = InviteSheetViewModel(challengeID: challengeID, challengeName: challengeName)
        let sheet = InviteSheetViewController(viewModel: viewModel)
        
        navigationController.present(sheet, animated: true)
    }
    
    private func showSettings() {
        let viewModel = ChallengeSettingsViewModel(challengeID: challengeID)
        let viewController = ChallengeSettingsViewController(viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        viewController.onEnded = { [weak self] in
            self?.replaceWithResult()
        }
        
        viewController.onDeleted = { [weak self] in
            self?.navigationController.popToRootViewController(animated: true)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showDetail() {
        let viewModel = ChallengeViewModel(challengeID: challengeID)
        let viewController = ChallengeViewController(viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        viewController.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        viewController.onInvite = { [weak self] challengeName in
            self?.showInviteSheet(challengeName: challengeName)
        }
        
        viewController.onSettings = { [weak self] in
            self?.showSettings()
        }
        
        viewController.onOpenPhoto = { [weak self] url, caption in
            let viewer = PhotoViewerViewController(url: url, caption: caption)
            self?.navigationController.present(viewer, animated: true)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func makeResult() -> ChallengeResultViewController {
        let viewModel = ChallengeResultViewModel(challengeID: challengeID)
        let viewController = ChallengeResultViewController(viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        viewController.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        return viewController
    }
    
    private func replaceWithResult() {
        var stack = navigationController.viewControllers
        stack.removeAll { $0 is ChallengeViewController || $0 is ChallengeSettingsViewController }
        stack.append(makeResult())
        
        navigationController.setViewControllers(stack, animated: true)
    }
}
