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
        showHome()
    }
    
    private func showHome() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
}
