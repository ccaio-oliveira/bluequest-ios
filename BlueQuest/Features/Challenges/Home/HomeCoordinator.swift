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
    private weak var homeViewController: HomeViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        homeViewController = viewController
        
        navigationController.setViewControllers([viewController], animated: false)
        
        viewController.onSelectChallenge = { [weak self] challengeID, state in
            self?.showChallenge(id: challengeID, destination: state == .closed ? .result : .detail)
        }
        
        viewController.onCreateChallenge = { [weak self] in
            self?.showCreateChallenge()
        }
        
        viewController.onOpenNotifications = { [weak self] in
            self?.showNotifications()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showClosedChallenges() {
        navigationController.popToRootViewController(animated: false)
        homeViewController?.showClosedChallenges()
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
    
    private func showNotifications() {
        let viewController = NotificationsViewController(viewModel: NotificationsViewModel())
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        viewController.onPreferences = { [weak self] in
            self?.showNotificationPreferences()
        }
        
        viewController.onSelectChallenge = { [weak self] challengeID, opensResult in
            self?.showChallenge(id: challengeID, destination: opensResult ? .result : .detail)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showNotificationPreferences() {
        let viewController = NotificationPreferencesViewController(viewModel: NotificationPreferencesViewModel())
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
