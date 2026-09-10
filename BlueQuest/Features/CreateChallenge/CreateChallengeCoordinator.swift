//
//  CreateChallengeCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/08/26.
//

import Foundation
import UIKit

final class CreateChallengeCoordinator: Coordinator {
    let navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = CreateChallengeViewModel()
        let viewController = CreateChallengeViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        
        viewController.onClose = { [weak self] in
            self?.dismiss()
        }
        
        viewController.onCreated = { [weak self] in
            self?.dismiss()
        }
        
        navigationController.present(viewController, animated: true)
    }
    
    private func dismiss() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
}
