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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
