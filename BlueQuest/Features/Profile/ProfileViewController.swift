//
//  ProfileViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    var onLogout: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg0
        
        let user = Session.shared.currentUser
        
        let avatar = AvatarView(size: 72)
        avatar.configure(name: user?.name ?? "?")
        
        let nameLabel = UILabel()
        nameLabel.text = user?.name ?? "Sua conta"
        nameLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        nameLabel.textColor = .bqText1
        nameLabel.textAlignment = .center
        
        let emailLabel = UILabel()
        emailLabel.text = user?.email
        emailLabel.font = BQFont.body(BQTypeScale.caption)
        emailLabel.textColor = .bqText3
        
        let header = UIStackView(arrangedSubviews: [avatar, nameLabel, emailLabel])
        header.axis = .vertical
        header.spacing = BQSpacing.sp2
        header.alignment = .center
        
        let logoutRow = ListRowView(
            icon: "rectangle.portrait.and.arrow.right",
            title: "Sair",
            showsChevron: false,
            isDestructive: true
        )
        logoutRow.addTarget(self, action: #selector(confirmLogout), for: .touchUpInside)
        
        let logoutGroup = ListGroupView()
        logoutGroup.setRows([logoutRow])
        
        let stack = UIStackView(arrangedSubviews: [header, logoutGroup])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp6
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: BQSpacing.sp5),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc private func confirmLogout() {
        let alert = UIAlertController(
            title: "Sair da conta?",
            message: "Seus desafios e pontuações continuam salvos.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Sair", style: .destructive) { [weak self] _ in
            Task {
                try? await AuthService.shared.logout()
                Session.shared.end()
                self?.onLogout?()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Calendar", style: .cancel))
        
        present(alert, animated: true)
    }
}
