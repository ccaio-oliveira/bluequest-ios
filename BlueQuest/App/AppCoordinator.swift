//
//  AppCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if Session.shared.isAuthenticated {
            showHome()
        } else {
            showAuth()
        }
    }
    
    private func showAuth() {
        childCoordinators.removeAll()
        
        let coordinator = AuthCoordinator(navigationController: navigationController)
        coordinator.onAuthenticated = { [weak self] in
            self?.showHome()
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    private func showHome() {
        childCoordinators.removeAll()
        
        let coordinator = HomeCoordinator(navigationController: navigationController)
        
        coordinator.onLogout = { [weak self] in
            self?.showAuth()
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
