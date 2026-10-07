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
    var onHistory: (() -> Void)?
    var onNotifications: (() -> Void)?
    var onClosedChallenges: (() -> Void)?
    
    private let viewModel: ProfileViewModel
    
    private let avatar = AvatarView(size: 72)
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let statsRow = UIStackView()
    private let permissionsRow = ListRowView(icon: "hand.raised", title: "Permissões", subtitle: "Câmera e notificações")
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg0
        
        nameLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        nameLabel.textColor = .bqText1
        nameLabel.textAlignment = .center
        
        emailLabel.font = BQFont.body(BQTypeScale.caption)
        emailLabel.textColor = .bqText3
        
        let header = UIStackView(arrangedSubviews: [avatar, nameLabel, emailLabel])
        header.axis = .vertical
        header.spacing = BQSpacing.sp2
        header.alignment = .center
        
        statsRow.axis = .horizontal
        statsRow.spacing = BQSpacing.sp2
        statsRow.distribution = .fillEqually
        
        let notificationsRow = ListRowView(
            icon: "bell",
            title: "Notificações",
            subtitle: "Lembretes e avisos dos desafios"
        )
        notificationsRow.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)
        
        permissionsRow.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        let historyRow = ListRowView(
            icon: "calendar",
            title: "Seu histórico",
            subtitle: "Conclusões por dia"
        )
        historyRow.addTarget(self, action: #selector(handleHistory), for: .touchUpInside)
        
        let closedRow = ListRowView(
            icon: "flag.checkered",
            title: "Desafios encerrados",
            subtitle: "Resultados finais"
        )
        closedRow.addTarget(self, action: #selector(handleClosedChallenges), for: .touchUpInside)
        
        let mainGroup = ListGroupView()
        mainGroup.setRows([notificationsRow, permissionsRow, historyRow, closedRow])
        
        let logoutRow = ListRowView(
            icon: "rectangle.portrait.and.arrow.right",
            title: "Sair",
            showsChevron: false,
            isDestructive: true
        )
        logoutRow.addTarget(self, action: #selector(confirmLogout), for: .touchUpInside)
        
        let logoutGroup = ListGroupView()
        logoutGroup.setRows([logoutRow])
        
        let stack = UIStackView(arrangedSubviews: [header, statsRow, mainGroup, logoutGroup])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp6
        stack.setCustomSpacing(BQSpacing.sp5, after: header)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: BQSpacing.sp5),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
        ])
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionUserDidChange), name: .sessionUserDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        renderUser()
        render()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        Task { await viewModel.load() }
    }
    
    private func renderUser() {
        let user = Session.shared.currentUser
        
        avatar.configure(name: user?.name ?? "?")
        nameLabel.text = user?.name ?? "Sua conta"
        emailLabel.text = user?.email
        emailLabel.isHidden = user?.email == nil
    }
    
    private func render() {
        let stats = viewModel.stats
        
        statsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        [
            StatTileView(icon: "flag.fill", value: stats.map { "\($0.challenges)" } ?? "–", label: "desafios"),
            StatTileView(icon: "bolt.fill", value: stats.map { "\($0.points)" } ?? "–", label: "pontos totais", tone: .points),
            StatTileView(icon: "trophy.fill", value: stats.map { "\($0.wins)" } ?? "–", label: stats?.wins == 1 ? "vitória" : "vitórias", tone: .primary)
        ].forEach { statsRow.addArrangedSubview($0) }
        
        permissionsRow.setSubtitle(viewModel.permissionsText)
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
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func sessionUserDidChange() {
        renderUser()
    }
    
    @objc private func appDidBecomeActive() {
        Task { await viewModel.load() }
    }
    
    @objc private func handleHistory() {
        onHistory?()
    }
    
    @objc private func handleNotifications() {
        onNotifications?()
    }
    
    @objc private func handleClosedChallenges() {
        onClosedChallenges?()
    }
}
