//
//  HomeCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

final class HomeCoordinator: Coordinator {
    let navigationController: UINavigationController
    var onLogout: (() -> Void)?
    
    private var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        
        viewController.onSelectChallenge = { [weak self] challengeID, state in
            self?.showChallenge(id: challengeID, destination: state == .closed ? .result : .detail)
        }
        
        viewController.onCreateChallenge = { [weak self] in
            self?.showCreateChallenge()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showChallenge(id: Int, destination: ChallengeCoordinator.Destination) {
        let coordinator = ChallengeCoordinator(
            navigationController: navigationController,
            challengeID: id,
            destination: destination
        )
        
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.childCoordinators.removeAll { $0 === coordinator }
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    private func showCreateChallenge() {
        let coordinator = CreateChallengeCoordinator(navigationController: navigationController)
        
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.childCoordinators.removeAll { $0 === coordinator }
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
