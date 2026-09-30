//
//  NotificationPreferencesViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation
import UIKit

final class NotificationPreferencesViewController: UIViewController {
    var onBack: (() -> Void)?
    
    private let viewModel: NotificationPreferencesViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let permissionBanner = BannerView()
    private let groupsStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorState = EmptyStateView(
        icon: "exclamationmark.triangle",
        title: "Não foi possível carregar",
        message: "Verifique sua conexão e tente de novo.",
        actionTitle: "Tentar de novo",
        actionIcon: "arrow.clockwise"
    )
    private let toast = ToastView()
    
    private var switchRows: [(row: NotificationPreferenceRow, view: ListSwitchRowView)] = []
    
    init(viewModel: NotificationPreferencesViewModel) {
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
        
        viewModel.onSaveError = { [weak self] message in
            self?.showToast(message)
        }
        
        permissionBanner.onAction = { [weak self] in
            self?.handlePermissionAction()
        }
        
        errorState.onAction = { [weak self] in
            Task { await self?.viewModel.load() }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        render()
        
        Task { await viewModel.load() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = BQSpacing.sp4
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        groupsStack.axis = .vertical
        groupsStack.spacing = BQSpacing.sp5
        groupsStack.addArrangedSubview(makeGroup(title: "Lembretes neste iPhone", rows: NotificationPreferencesViewModel.deviceRows))
        groupsStack.addArrangedSubview(makeGroup(title: "Atividade dos desafios", rows: NotificationPreferencesViewModel.activityRows))
        
        permissionBanner.isHidden = true
        
        [makeHeader(), permissionBanner, loadingIndicator, errorState, groupsStack].forEach { contentStack.addArrangedSubview($0) }
        
        toast.isHidden = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        
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
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding),
            
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }
    
    private func makeHeader() -> UIView {
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Preferências"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "O que o BlueQuest avisa pra você"
        subtitleLabel.font = BQFont.body(BQTypeScale.caption)
        subtitleLabel.textColor = .bqText3
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleStack])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        return headerRow
    }
    
    private func makeGroup(title: String, rows: [NotificationPreferenceRow]) -> UIView {
        let group = ListGroupView()
        
        group.setRows(rows.map { row in
            let view = ListSwitchRowView(icon: row.icon)
            
            view.onToggle = { [weak self] isOn in
                Task { await self?.viewModel.set(row.keyPath, to: isOn) }
            }
            
            switchRows.append((row, view))
            return view
        })
        
        let stack = UIStackView(arrangedSubviews: [OverlineLabel(title), group])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp2
        
        return stack
    }
    
    private func render() {
        loadingIndicator.isHidden = !viewModel.isLoading
        viewModel.isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        
        errorState.isHidden = viewModel.loadError == nil
        groupsStack.isHidden = viewModel.preferences == nil
        
        if let banner = viewModel.permissionBanner {
            permissionBanner.configure(text: banner.text, tone: .info, systemIcon: "bell.slash", actionTitle: banner.actionTitle)
            permissionBanner.isHidden = false
        } else {
            permissionBanner.isHidden = true
        }
        
        guard let preferences = viewModel.preferences else { return }
        
        for (row, view) in switchRows {
            view.configure(title: row.title, subtitle: row.subtitle, isOn: preferences[keyPath: row.keyPath], isEnabled: true)
        }
    }
    
    private func handlePermissionAction() {
        if viewModel.permissionStatus == .denied {
            openSettings()
        } else {
            Task { await viewModel.requestPermission() }
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func showToast(_ message: String) {
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
    
    @objc private func appDidBecomeActive() {
        Task { await viewModel.refreshPermission() }
    }
    
    @objc private func handleBack() {
        onBack?()
    }
}
