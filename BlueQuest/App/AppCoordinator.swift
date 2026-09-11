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
    
    private var pendingInviteCode: String?
    private weak var mainTab: MainTabCoordinator?
    
    private var topViewController: UIViewController? {
        var top = window.rootViewController
        
        while let presented = top?.presentedViewController {
            top = presented
        }
        
        return top
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if Session.shared.isAuthenticated {
            showMain()
            refreshCurrentUser()
        } else {
            showAuth()
        }
    }
    
    func handle(url: URL) {
        guard url.scheme == "bluequest", url.host == "invite" else { return }
        
        let code = url.lastPathComponent
        guard !code.isEmpty, code != "/" else { return }
        
        if Session.shared.isAuthenticated {
            presentInvite(code: code)
        } else {
            pendingInviteCode = code
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
        
        mainTab = coordinator
        window.rootViewController = coordinator.tabBarController
        
        if let code = pendingInviteCode {
            pendingInviteCode = nil
            DispatchQueue.main.async { [weak self] in
                self?.presentInvite(code: code)
            }
        }
    }
    
    private func presentInvite(code: String) {
        guard let presenter = topViewController else { return }
        
        let viewModel = InviteViewModel(code: code)
        let viewController = InviteViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        
        viewController.onClose = { [weak presenter] in
            presenter?.dismiss(animated: true)
        }
        
        viewController.onOpenChallenge = { [weak self, weak presenter] _ in
            presenter?.dismiss(animated: true) {
                self?.mainTab?.selectChallengesTab()
            }
        }
        
        presenter.present(viewController, animated: true)
    }
    
    private func refreshCurrentUser() {
        Task { [weak self] in
            do {
                let user = try await AuthService.shared.currentUser()
                Session.shared.update(user: user)
            } catch APIError.unauthorized {
                Session.shared.end()
                self?.showAuth()
            } catch {
                // Sem rede ou servidor fora: mantém a sessão e tenta de novo na próxima abertura
            }
        }
    }
}
