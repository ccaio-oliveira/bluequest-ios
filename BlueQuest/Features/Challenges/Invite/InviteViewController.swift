//
//  InviteViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

final class InviteViewController: UIViewController {
    var onClose: (() -> Void)?
    var onOpenChallenge: ((Int) -> Void)?
    
    private let viewModel: InviteViewModel
    
    private let card = UIView()
    private let cardStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: InviteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg0
        
        setupLayout()
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        viewModel.onAccepted = { [weak self] challengeID in
            self?.onOpenChallenge?(challengeID)
        }
        
        render()
        
        Task { await viewModel.load() }
    }
    
    private func setupLayout() {
        let overline = UILabel()
        overline.attributedText = NSAttributedString(
            string: "CONVITE RECEBIDO",
            attributes: [.kern: BQTypeScale.micro * 0.08]
        )
        overline.font = BQFont.body(BQTypeScale.micro, weight: .semibold)
        overline.textColor = .bqText3
        
        let closeButton = IconButtonView(icon: "xmark")
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        let headerRow = UIStackView(arrangedSubviews: [overline, UIView(), closeButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        
        card.backgroundColor = .bqBg1
        card.layer.cornerRadius = BQRadius.large
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.bqStroke1.cgColor
        
        cardStack.axis = .vertical
        cardStack.spacing = 14
        cardStack.alignment = .center
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(cardStack)
        
        loadingIndicator.color = .bqText2
        loadingIndicator.hidesWhenStopped = true
        
        let mainStack = UIStackView(arrangedSubviews: [headerRow, card, loadingIndicator])
        mainStack.axis = .vertical
        mainStack.spacing = BQSpacing.sp4
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: BQSpacing.sp5),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -BQSpacing.sp5),
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: BQSpacing.sp5),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -BQSpacing.sp5),
            
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: BQSpacing.sp3),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
        ])
    }
    
    private func render() {
        cardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if viewModel.isLoading && viewModel.preview == nil {
            loadingIndicator.startAnimating()
            card.isHidden = true
            return
        }
        
        loadingIndicator.stopAnimating()
        card.isHidden = false
        
        guard let preview = viewModel.preview else {
            renderMessage(
                icon: "excalmationmark.triangle.fill",
                title: "Não foi possível abrir o convite",
                message: viewModel.errorMessage ?? "Tente novamente em instantes.",
                actionTitle: "Voltar",
                action: { [weak self] in self?.onClose?() }
            )
            
            return
        }
        
        switch preview.state {
        case .valid:
            renderValid(preview)
            
        case .invalid:
            renderMessage(
                icon: "link",
                title: "Convite inválido",
                message: "O link está incorreto ou foi desativado por quem criou o desafio.",
                actionTitle: "Voltar",
                action: { [weak self] in self?.onClose?() }
            )
            
        case .challengeClosed:
            renderMessage(
                icon: "flag.fill",
                title: "Desafio encerrado",
                message: "Este desafio já terminou e não aceita novos participantes.",
                actionTitle: "Voltar",
                action: { [weak self] in self?.onClose?() }
            )
            
        case .alreadyParticipant:
            renderMessage(
                icon: "checkmark.circle.fill",
                title: "Você já está neste desafio",
                message: "Sua participação continua valendo - nada muda.",
                actionTitle: "Abrir desafio",
                action: { [weak self] in
                    guard let id = preview.challengeID else { return }
                    self?.onOpenChallenge?(id)
                }
            )
        }
    }
    
    private func renderValid(_ preview: InvitePreview) {
        let avatarsRow = UIStackView()
        avatarsRow.axis = .horizontal
        avatarsRow.spacing = -10
        
        for name in preview.participantNames.prefix(4) {
            let avatar = AvatarView(size: 44)
            avatar.configure(name: name)
            avatarsRow.addArrangedSubview(avatar)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = preview.name
        nameLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        nameLabel.textColor = .bqText1
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        
        let metaLabel = UILabel()
        metaLabel.text = [
            preview.invitedBy.map { "\($0) convidou você" },
            preview.periodText,
            "\(preview.participantsCount) \(preview.participantsCount == 1 ? "participante" : "participantes")"
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
        metaLabel.font = BQFont.body(BQTypeScale.caption)
        metaLabel.textColor = .bqText3
        metaLabel.textAlignment = .center
        metaLabel.numberOfLines = 0
        
        let daysBadge = BadgeView()
        daysBadge.configure(text: "\(preview.totalDays) dias", tone: .available, systemIcon: "calendar")
        
        let pointsBadge = BadgeView()
        pointsBadge.configure(text: "até \(preview.maxPointsPerDay) pts/dia", tone: .points, systemIcon: "bolt.fill")
        
        let tasksBadge = BadgeView()
        tasksBadge.configure(text: "\(preview.tasksCount) \(preview.tasksCount == 1 ? "tarefa" : "tarefas")", tone: .neutral, systemIcon: "checkmark.circle.fill")
        
        let badgesRow = UIStackView(arrangedSubviews: [daysBadge, pointsBadge, tasksBadge])
        badgesRow.axis = .horizontal
        badgesRow.spacing = BQSpacing.sp2
        
        let joinButton = BQButton(title: "Entrar no desafio", size: .lg)
        joinButton.setLoading(viewModel.isAccepting)
        joinButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        
        let laterButton = BQButton(title: "Agora não", variant: .ghost)
        laterButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        [avatarsRow, nameLabel, metaLabel, badgesRow, joinButton, laterButton].forEach { cardStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            joinButton.leadingAnchor.constraint(equalTo: cardStack.leadingAnchor),
            joinButton.trailingAnchor.constraint(equalTo: cardStack.trailingAnchor),
            laterButton.leadingAnchor.constraint(equalTo: cardStack.leadingAnchor),
            laterButton.trailingAnchor.constraint(equalTo: cardStack.trailingAnchor)
        ])
        
        if let error = viewModel.errorMessage {
            let errorLabel = UILabel()
            errorLabel.text = error
            errorLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
            errorLabel.textColor = .bqRed
            errorLabel.textAlignment = .center
            errorLabel.numberOfLines = 0
            cardStack.insertArrangedSubview(errorLabel, at: cardStack.arrangedSubviews.count - 2)
        }
    }
    
    private func renderMessage(
        icon: String,
        title: String,
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        let empty = EmptyStateView(icon: icon, title: title, message: message, actionTitle: actionTitle)
        empty.onAction = action
        cardStack.addArrangedSubview(empty)
        
        NSLayoutConstraint.activate([
            empty.leadingAnchor.constraint(equalTo: cardStack.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: cardStack.trailingAnchor)
        ])
    }
    
    @objc private func handleClose() {
        onClose?()
    }
    
    @objc private func handleAccept() {
        Task { await viewModel.accept() }
    }
}
