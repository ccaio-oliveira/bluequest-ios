//
//  AuthCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 12/08/26.
//

import Foundation
import UIKit

final class AuthCoordinator: Coordinator {
    let navigationController: UINavigationController
    var onAuthenticated: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = AuthViewModel()
        let viewController = AuthViewController(viewModel: viewModel)
        
        viewController.onAuthenticated = { [weak self] in
            self?.onAuthenticated?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}
