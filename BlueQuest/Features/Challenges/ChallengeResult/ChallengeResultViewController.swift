//
//  ChallengeResultViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 16/09/26.
//

import Foundation
import UIKit

final class ChallengeResultViewController: UIViewController {
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    private let viewModel: ChallengeResultViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let resultStack = UIStackView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let podiumView = PodiumView()
    private let rowsStack = UIStackView()
    private let statsRow = UIStackView()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private let retryButton = BQButton(title: "Tentar de novo", icon: "arrow.clockwise", variant: .secondary)
    private let errorStack = UIStackView()
    
    init(viewModel: ChallengeResultViewModel) {
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
        
        render()
        
        Task { await viewModel.load() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            onFinish?()
        }
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        rowsStack.axis = .vertical
        rowsStack.spacing = 2
        
        statsRow.axis = .horizontal
        statsRow.spacing = BQSpacing.sp2
        statsRow.distribution = .fillEqually
        
        let footnoteLabel = UILabel()
        footnoteLabel.text = "Desafios encerrados ficam no histórico com tarefas, conclusões e ranking final preservados."
        footnoteLabel.font = BQFont.body(12)
        footnoteLabel.textColor = .bqText3
        footnoteLabel.textAlignment = .center
        footnoteLabel.numberOfLines = 0
        
        resultStack.axis = .vertical
        resultStack.spacing = 18
        resultStack.isHidden = true
        
        [podiumView, rowsStack, statsRow, footnoteLabel].forEach {
            resultStack.addArrangedSubview($0)
        }
        
        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(resultStack)
        
        loadingIndicator.color = .bqText3
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        errorLabel.font = BQFont.body(BQTypeScale.body)
        errorLabel.textColor = .bqText2
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        errorStack.axis = .vertical
        errorStack.spacing = BQSpacing.sp4
        errorStack.alignment = .center
        errorStack.addArrangedSubview(errorLabel)
        errorStack.addArrangedSubview(retryButton)
        errorStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorStack)
        
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
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            errorStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
            
        ])
    }
    
    private func makeHeader() -> UIView {
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = BQFont.body(BQTypeScale.caption)
        subtitleLabel.textColor = .bqText3
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        
        let badge = BadgeView()
        badge.configure(text: "Encerrado", tone: .neutral, systemIcon: nil)
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleStack, badge])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        return headerRow
    }
    
    private func render() {
        if viewModel.isLoading && viewModel.stats == nil {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        errorLabel.text = viewModel.errorMessage
        errorStack.isHidden = viewModel.errorMessage == nil
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        guard let stats = viewModel.stats else { return }
        
        resultStack.isHidden = false
        podiumView.configure(with: viewModel.podium)
        
        rowsStack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        viewModel.rows.forEach { row in
            let view = RankingRowView()
            view.configure(with: row)
            rowsStack.addArrangedSubview(view)
        }
        
        rowsStack.isHidden = viewModel.rows.isEmpty
        
        statsRow.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        [
            StatTileView(icon: "bolt.fill", value: "\(stats.points)", label: "seus pontos", tone: .points),
            StatTileView(icon: "checkmark.circle.fill", value: "\(stats.completedCount)", label: "concluídas"),
            StatTileView(icon: "hourglass", value: "\(stats.expiredCount)", label: "expiradas")
        ].forEach { statsRow.addArrangedSubview($0) }
    }
    
    @objc private func handleBack() {
        onBack?()
    }
    
    @objc private func handleRetry() {
        Task { await viewModel.load() }
    }
}
