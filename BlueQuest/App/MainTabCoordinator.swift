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
    }
    
    func selectChallengesTab() {
        tabBarController.selectedIndex = 3
    }
    
    private func makeChallengesTab() -> UIViewController {
        let navigationController = BQNavigationController()
        
        let coordinator = HomeCoordinator(navigationController: navigationController)
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
        let profile = ProfileViewController()
        profile.onLogout = { [weak self] in
            self?.onLogout?()
        }
        
        let navigationController = BQNavigationController(rootViewController: profile)
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
}
