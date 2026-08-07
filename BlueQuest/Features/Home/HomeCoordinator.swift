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
    
    private var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        
        viewController.onSelectChallenge = { [weak self] challengeID in
            self?.showChallenge(id: challengeID)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showChallenge(id: Int) {
        let coordinator = ChallengeCoordinator(navigationController: navigationController, challengeID: id)
        
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.childCoordinators.removeAll { $0 === coordinator }
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
