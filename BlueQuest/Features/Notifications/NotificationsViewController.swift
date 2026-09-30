//
//  NotificationsViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation
import UIKit

final class NotificationsViewController: UIViewController {
    var onBack: (() -> Void)?
    var onPreferences: (() -> Void)?
    var onSelectChallenge: ((_ challengeID: Int, _ opensResult: Bool) -> Void)?
    
    private let viewModel: NotificationsViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let listGroup = ListGroupView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyState = EmptyStateView(
        icon: "bell",
        title: "Nada por aqui",
        message: "Avisaremos quando alguém entrar nos seus desafios, passar você no ranking ou quando um desafio terminar."
    )
    private let errorState = EmptyStateView(
        icon: "exclamationmark.triangle",
        title: "Não foi possível carregar",
        message: "Verifique sua conexão e tente de novo.",
        actionTitle: "Tentar de novo",
        actionIcon: "arrow.clockwise"
    )
    
    init(viewModel: NotificationsViewModel) {
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
        
        errorState.onAction = { [weak self] in
            Task { await self?.viewModel.load() }
        }
        
        render()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        Task { await viewModel.load() }
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = BQSpacing.sp4
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStack)
        
        [makeHeader(), loadingIndicator, errorState, emptyState, listGroup].forEach { contentStack.addArrangedSubview($0) }
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp8),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
    }
    
    private func makeHeader() -> UIView {
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Notificações"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        let preferencesButton = IconButtonView(icon: "slider.horizontal.3")
        preferencesButton.addTarget(self, action: #selector(handlePreferences), for: .touchUpInside)
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleLabel, UIView(), preferencesButton])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        return headerRow
    }
    
    private func render() {
        let hasRows = !viewModel.rows.isEmpty
        
        loadingIndicator.isHidden = !viewModel.isLoading
        viewModel.isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        
        errorState.isHidden = viewModel.errorMessage == nil || hasRows
        emptyState.isHidden = viewModel.isLoading || viewModel.errorMessage != nil || hasRows
        listGroup.isHidden = !hasRows
        
        listGroup.setRows(viewModel.rows.map { row in
            let view = NotificationRowView()
            view.configure(with: row.card)
            view.onTap = { [weak self] in
                guard let challengeID = row.challengeID else { return }
                self?.onSelectChallenge?(challengeID, row.opensResult)
            }
            return view
        })
    }
    
    @objc private func handleBack() {
        onBack?()
    }
    
    @objc private func handlePreferences() {
        onPreferences?()
    }
}
