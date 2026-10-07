//
//  MainTabCoordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

@MainActor
final class MainTabCoordinator: Coordinator {
    let tabBarController = UITabBarController()
    var onLogout: (() -> Void)?
    
    private var childCoordinators: [Coordinator] = []
    private weak var homeCoordinator: HomeCoordinator?
    private var offlineBanner = BannerView()
    private var connectivityObserver: NSObjectProtocol?
    
    func start() {
        tabBarController.viewControllers = [
            makePlaceholderTab(
                title: "Início",
                icon: "house",
                selectedIcon: "house.fill",
                emptyTitle: "Dashboard em construção",
                message: "Aqui vão aparecer o treino do dia, seus números da semana e o resumo dos desafios."
            ),
            
            makePlaceholderTab(
                title: "Treino",
                icon: "dumbbell",
                selectedIcon: "dumbbell.fill",
                emptyTitle: "Treino em construção",
                message: "Sua ficha, o treino do dia e a execução série a série vão morar aqui."
            ),
            
            makePlaceholderTab(
                title: "Evolução",
                icon: "chart.line.uptrend.xyaxis",
                selectedIcon: "chart.line.uptrend.xyaxis",
                emptyTitle: "Evolução em construção",
                message: "Gráficos de carga e peso, recordes e avaliações físicas com comparação."
            ),
            
            makeChallengesTab(),
            makeProfileTab()
        ]
        
        tabBarController.selectedIndex = 3
        setupOfflineBanner()
    }
    
    func selectChallengesTab() {
        tabBarController.selectedIndex = 3
    }
    
    private func makeChallengesTab() -> UIViewController {
        let navigationController = BQNavigationController()
        
        let coordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator = coordinator
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Desafios",
            image: UIImage(systemName: "flag"),
            selectedImage: UIImage(systemName: "flag.fill")
        )
        
        return navigationController
    }
    
    private func makeProfileTab() -> UIViewController {
        let navigationController = BQNavigationController()
        
        let coordinator = ProfileCoordinator(navigationController: navigationController)
        coordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }
        
        coordinator.onShowClosedChallenges = { [weak self] in
            self?.selectChallengesTab()
            self?.homeCoordinator?.showClosedChallenges()
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
        
        navigationController.tabBarItem = UITabBarItem(
            title: "Perfil",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        return navigationController
    }
    
    private func makePlaceholderTab(
        title: String,
        icon: String,
        selectedIcon: String,
        emptyTitle: String,
        message: String
    ) -> UIViewController {
        let placeholder = PlaceholderViewController(icon: selectedIcon, title: emptyTitle, message: message)
        
        let navigationController = BQNavigationController(rootViewController: placeholder)
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: selectedIcon)
        )
        
        return navigationController
    }
    
    private func setupOfflineBanner() {
        let container: UIView = tabBarController.view
        
        offlineBanner.configure(text: "Sem conexão. Suas conclusões serão enviadas quando ela voltar.", tone: .offline)
        offlineBanner.alpha = 0
        offlineBanner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(offlineBanner)
        
        NSLayoutConstraint.activate([
            offlineBanner.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: BQSpacing.screenPadding),
            offlineBanner.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -BQSpacing.screenPadding),
            offlineBanner.bottomAnchor.constraint(equalTo: tabBarController.tabBar.topAnchor, constant: -BQSpacing.sp2)
        ])
        
        connectivityObserver = NotificationCenter.default.addObserver(
            forName: .connectivityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateOfflineBanner(animated: true)
            }
        }
        
        updateOfflineBanner(animated: false)
    }
    
    private func updateOfflineBanner(animated: Bool) {
        let isOffline = !ConnectivityMonitor.shared.isOnline
        
        tabBarController.view.layoutIfNeeded()
        let inset = isOffline ? offlineBanner.bounds.height + BQSpacing.sp2 : 0
        
        let changes = {
            self.offlineBanner.alpha = isOffline ? 1 : 0
            self.tabBarController.viewControllers?.forEach { $0.additionalSafeAreaInsets.bottom = inset }
            self.tabBarController.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
    }
    
    deinit {
        if let connectivityObserver {
            NotificationCenter.default.removeObserver(connectivityObserver)
        }
    }
}
