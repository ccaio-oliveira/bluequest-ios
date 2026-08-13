//
//  HomeViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

final class HomeViewController: UIViewController {
    var onSelectChallenge: ((Int) -> Void)?
    var onLogout: (() -> Void)?
    var onCreateChallenge: (() -> Void)?
    
    private let viewModel: HomeViewModel

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let tasksStack = UIStackView()
    private let headerView = HomeHeaderView()
    private let challengesSectionLabel = UILabel()
    private let challengesStack = UIStackView()
    private let createButton = BQButton(title: "Criar desafio", icon: "plus", variant: .primary, size: .lg)
    private let pointsPill = PointsPillView(size: .lg)
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private let retryButton = BQButton(title: "Tentar de novo", icon: "arrow.clockwise", variant: .secondary)
    private let errorStack = UIStackView()
    private let refreshControl = UIRefreshControl()
    private let toast = ToastView()
    
    private var hasLoadedOnce = false
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            icon: "flag.fill",
            title: "Nenhum desafio ainda",
            message: "Crie um desafio com tarefas e pontos, convide pessoas e acompanhem o ranking. Convites recebidos entram automaticamente.",
            actionTitle: "Criar desafio",
            actionIcon: "plus"
        )
        
        view.onAction = { [weak self] in
            self?.onCreateChallenge?()
        }
        
        return view
    }()
    
    init(viewModel: HomeViewModel) {
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
        
        headerView.onProfileTap = { [weak self] in
            self?.confirmLogout()
        }
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        viewModel.onPointsAwarded = { [weak self] points in
            self?.showPointsPop(points: points)
        }
        
        viewModel.onActionError = { [weak self] message in
            self?.showErrorToast(message)
        }
        
        Task {
            await viewModel.load()
            hasLoadedOnce = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if hasLoadedOnce {
            Task { await viewModel.load(showingLoader: false) }
        }
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = BQSpacing.sp5
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        challengesSectionLabel.font = BQFont.body(BQTypeScale.micro, weight: .semibold)
        challengesSectionLabel.textColor = .bqText3
        challengesSectionLabel.attributedText = NSAttributedString(
            string: "SEUS DESAFIOS",
            attributes: [.kern: BQTypeScale.micro * 0.08]
        )
        
        challengesStack.axis = .vertical
        challengesStack.spacing = BQSpacing.sp2
        
        let challengesSection = UIStackView(arrangedSubviews: [challengesSectionLabel, challengesStack])
        challengesSection.axis = .vertical
        challengesSection.spacing = 10
        
        tasksStack.axis = .vertical
        tasksStack.spacing = BQSpacing.sp2
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(tasksStack)
        contentStack.addArrangedSubview(challengesSection)
        contentStack.addArrangedSubview(createButton)
        
        pointsPill.isHidden = true
        pointsPill.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pointsPill)
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pointsPill.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pointsPill.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            
            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp6),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
        
        loadingIndicator.color = .bqText2
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        errorLabel.font = BQFont.body(BQTypeScale.body)
        errorLabel.textColor = .bqText2
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        emptyStateView.isHidden = true
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        createButton.addTarget(self, action: #selector(handleCreateChallenge), for: .touchUpInside)
        
        errorStack.axis = .vertical
        errorStack.spacing = BQSpacing.sp4
        errorStack.alignment = .center
        errorStack.isHidden = true
        errorStack.addArrangedSubview(errorLabel)
        errorStack.addArrangedSubview(retryButton)
        errorStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorStack)
        
        toast.isHidden = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        
        refreshControl.tintColor = .bqText3
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.sp10),
            errorStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.sp10),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }
    
    private func render() {
        let isEmpty = !viewModel.hasContent
        let hasFailed = viewModel.errorMessage != nil
        
        if viewModel.isLoading && isEmpty {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        errorStack.isHidden = !(hasFailed && isEmpty)
        errorLabel.text = viewModel.errorMessage
        
        emptyStateView.isHidden = !(isEmpty && !viewModel.isLoading && !hasFailed)
        
        scrollView.isHidden = isEmpty
        
        if !viewModel.isLoading {
            refreshControl.endRefreshing()
        }
        
        guard !isEmpty else { return }
        
        headerView.configure(with: viewModel.header)
        renderTasks()
        renderChallenges()
    }
    
    private func renderTasks() {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard !viewModel.rows.isEmpty else {
            tasksStack.addArrangedSubview(makeNoTasksTodayCard())
            return
        }
        
        for row in viewModel.rows {
            let card = TaskCardView()
            card.configure(with: row.card)
            card.onComplete = { [weak self] in
                guard let self else { return }
                Task { await self.viewModel.completeTask(taskID: row.taskID) }
            }
            
            tasksStack.addArrangedSubview(card)
        }
    }
    
    private func renderChallenges() {
        challengesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for challenge in viewModel.challenges {
            let card = ChallengeCardView()
            card.configure(with: challenge)
            card.onTap = { [weak self] in
                self?.onSelectChallenge?(challenge.id)
            }
            challengesStack.addArrangedSubview(card)
        }
    }
    
    private func showPointsPop(points: Int) {
        pointsPill.configure(points: points)
        pointsPill.isHidden = false
        pointsPill.alpha = 0
        pointsPill.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5) {
            self.pointsPill.alpha = 1
            self.pointsPill.transform = .identity
        }
        
        UIView.animate(withDuration: 0.2, delay: 1.2) {
            self.pointsPill.alpha = 0
        } completion: { _ in
            self.pointsPill.isHidden = true
        }
    }
    
    private func confirmLogout() {
        let alert = UIAlertController(
            title: "Sair da conta?",
            message: "Você precisará entrar novamente para acessar seus desafios.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Sair", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        alert.popoverPresentationController?.sourceView = headerView
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        Task {
            await viewModel.logout()
            onLogout?()
        }
    }
    
    private func showErrorToast(_ message: String) {
        toast.configure(text: message, tone: .error, systemIcon: "exclamationmark.triangle.fill")
        toast.alpha = 0
        toast.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.toast.alpha = 1
        }
        
        UIView.animate(withDuration: 0.2, delay: 2.5) {
            self.toast.alpha = 0
        } completion: { _ in
            self.toast.isHidden = true
        }
    }
    
    private func makeNoTasksTodayCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .bqBg1
        card.layer.cornerRadius = BQRadius.medium
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.bqStroke1.cgColor
        
        let title = UILabel()
        title.text = "Nenhuma tarefa hoje"
        title.font = BQFont.body(BQTypeScale.body, weight: .semibold)
        title.textColor = .bqText2
        
        let message = UILabel()
        message.text = "As tarefas aparecem aqui nos dias em que precisam ser feitas."
        message.font = BQFont.body(BQTypeScale.caption)
        message.textColor = .bqText3
        message.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [title, message])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp1
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: BQSpacing.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -BQSpacing.cardPadding),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: BQSpacing.sp4),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -BQSpacing.sp4)
        ])
        
        return card
    }
    
    @objc private func handleRetry() {
        Task { await viewModel.load() }
    }
    
    @objc private func handleRefresh() {
        Task { await viewModel.load(showingLoader: false) }
    }
    
    @objc private func handleCreateChallenge() {
        onCreateChallenge?()
    }
}
