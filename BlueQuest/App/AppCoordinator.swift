//
//  AppCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if Session.shared.isAuthenticated {
            showMain()
        } else {
            showAuth()
        }
    }
    
    private func showAuth() {
        childCoordinators.removeAll()
        
        let navigationController = BQNavigationController()
        let coordinator = AuthCoordinator(navigationController: navigationController)
        coordinator.onAuthenticated = { [weak self] in
            self?.showMain()
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        window.rootViewController = navigationController
    }
    
    private func showMain() {
        childCoordinators.removeAll()
        
        let coordinator = MainTabCoordinator()
        
        coordinator.onLogout = { [weak self] in
            self?.showAuth()
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        window.rootViewController = coordinator.tabBarController
    }
}
