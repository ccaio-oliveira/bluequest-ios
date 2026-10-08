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
    
    private let notice: String?
    
    init(navigationController: UINavigationController, notice: String? = nil) {
        self.navigationController = navigationController
        self.notice = notice
    }
    
    func start() {
        let viewModel = AuthViewModel(notice: notice)
        let viewController = AuthViewController(viewModel: viewModel)
        
        viewController.onAuthenticated = { [weak self] in
            self?.onAuthenticated?()
        }
        
        viewController.onForgotPassword = { [weak self] email in
            self?.showPasswordReset(email: email)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showPasswordReset(email: String) {
        let viewModel = PasswordResetViewModel(email: email)
        let viewController = PasswordResetViewController(viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        viewModel.onAuthenticated = { [weak self] in
            self?.onAuthenticated?()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
