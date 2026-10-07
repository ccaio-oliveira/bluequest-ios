//
//  ProfileCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class ProfileCoordinator: Coordinator {
    let navigationController: UINavigationController
    var onLogout: (() -> Void)?
    var onShowClosedChallenges: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ProfileViewController(viewModel: ProfileViewModel())
        
        viewController.onLogout = { [weak self] in
            self?.onLogout?()
        }
        
        viewController.onHistory = { [weak self] in
            self?.showHistory()
        }
        
        viewController.onNotifications = { [weak self] in
            self?.showNotificationPreferences()
        }
        
        viewController.onClosedChallenges = { [weak self] in
            self?.onShowClosedChallenges?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showHistory() {
        let viewController = HistoryViewController(viewModel: HistoryViewModel())
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
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
