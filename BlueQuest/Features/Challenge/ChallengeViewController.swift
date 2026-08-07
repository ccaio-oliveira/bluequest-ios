//
//  ChallengeViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class ChallengeViewController: UIViewController {
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    private let viewModel: ChallengeViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let tabContentStack = UIStackView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressBar = ProgressBarView()
    private let dayLabel = UILabel()
    private let remainingLabel = UILabel()
    private let segmented = SegmentedControlView(options: ["Ranking", "Você", "Pessoas", "Tarefas"])
    
    init(viewModel: ChallengeViewModel) {
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
        render()
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
        
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = BQFont.body(BQTypeScale.caption)
        subtitleLabel.textColor = .bqText3
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 0
        
        let settingsButton = IconButtonView(icon: "gearshape")
        let inviteButton = IconButtonView(icon: "person.badge.plus", variant: .primary)
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleStack, settingsButton, inviteButton])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        dayLabel.font = BQFont.body(12)
        dayLabel.textColor = .bqText3
        remainingLabel.font = BQFont.body(12)
        remainingLabel.textColor = .bqText3
        remainingLabel.textAlignment = .right
        
        let progressMeta = UIStackView(arrangedSubviews: [dayLabel, UIView(), remainingLabel])
        progressMeta.axis = .horizontal
        
        let progressSection = UIStackView(arrangedSubviews: [progressBar, progressMeta])
        progressSection.axis = .vertical
        progressSection.spacing = 6
        
        segmented.onChange = { [weak self] _ in
            self?.renderTabContent()
        }
        
        tabContentStack.axis = .vertical
        tabContentStack.spacing = 2
        
        [headerRow, progressSection, segmented, tabContentStack].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp6),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
            
        ])
    }
    
    private func render() {
        let header = viewModel.header
        
        titleLabel.text = header.name
        subtitleLabel.text = header.subtitle
        progressBar.configure(value: header.day, total: header.totalDays)
        dayLabel.text = "Dia \(header.day) de \(header.totalDays)"
        remainingLabel.text = header.remainingText
        
        renderTabContent()
    }
    
    private func renderTabContent() {
        tabContentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        switch segmented.selectedIndex {
        case 0:
            for row in viewModel.ranking {
                let view = RankingRowView()
                
                view.configure(with: row)
                tabContentStack.addArrangedSubview(view)
            }
        default:
            let placeholder = UILabel()
            placeholder.text = "Em construção"
            placeholder.font = BQFont.body(BQTypeScale.caption)
            placeholder.textColor = .bqText3
            placeholder.textAlignment = .center
            
            tabContentStack.addArrangedSubview(placeholder)
        }
    }
    
    @objc private func handleBack() {
        onBack?()
    }
}
