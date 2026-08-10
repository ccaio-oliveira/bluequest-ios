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
    var onInvite: (() -> Void)?
    
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
        inviteButton.addTarget(self, action: #selector(handleInvite), for: .touchUpInside)
        
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
        tabContentStack.spacing = (segmented.selectedIndex == 0) ? 2 : BQSpacing.sp3
        
        switch segmented.selectedIndex {
        case 0:
            for row in viewModel.ranking {
                let view = RankingRowView()
                
                view.configure(with: row)
                tabContentStack.addArrangedSubview(view)
            }
        case 1:
            let stats = viewModel.personalStats
            let firstRow = UIStackView(arrangedSubviews: [
                StatTileView(icon: "bolt.fill", value: "\(stats.points)", label: "pontos", tone: .points),
                StatTileView(icon: "trophy.fill", value: "\(stats.position)º", label: "posição", tone: .primary)
            ])
            
            firstRow.axis = .horizontal
            firstRow.spacing = BQSpacing.sp2
            firstRow.distribution = .fillEqually
            
            let secondRow = UIStackView(arrangedSubviews: [
                StatTileView(icon: "checkmark.circle.fill", value: "\(stats.completedCount)", label: "tarefas concluídas"),
                StatTileView(icon: "flame.fill", value: "\(stats.streakDays)", label: "dias seguidos")
            ])
            secondRow.axis = .horizontal
            secondRow.spacing = BQSpacing.sp2
            secondRow.distribution = .fillEqually
            
            tabContentStack.addArrangedSubview(firstRow)
            tabContentStack.addArrangedSubview(secondRow)
            
            tabContentStack.addArrangedSubview(makeUsageCard(stats: stats))
        case 2:
            let group = ListGroupView()
            group.setRows(viewModel.participantRows.map { row in
                let view = ParticipantRowView()
                view.configure(with: row)
                return view
            })
            tabContentStack.addArrangedSubview(group)
        case 3:
            let intro = UILabel()
            intro.text = "Tarefas configuradas neste desafio"
            intro.font = BQFont.body(12)
            intro.textColor = .bqText3
            tabContentStack.addArrangedSubview(intro)
            
            for row in viewModel.taskRows {
                let card = TaskCardView()
                card.configure(with: row.card)
                tabContentStack.addArrangedSubview(card)
            }
            
            let recurrences = UILabel()
            recurrences.text = "Recorrências: " + viewModel.taskRows
                .map(\.recurrenceText)
                .joined(separator: " · ")
            recurrences.font = BQFont.body(12)
            recurrences.textColor = .bqText3
            recurrences.numberOfLines = 0
            tabContentStack.addArrangedSubview(recurrences)
            
            tabContentStack.spacing = switch segmented.selectedIndex {
            case 0: 2
            case 3: BQSpacing.sp2
            default: BQSpacing.sp3
            }
        default:
            break
        }
    }
    
    private func makeUsageCard(stats: ChallengePersonalStats) -> UIView {
        let card = UIView()
        card.backgroundColor = .bqBg1
        card.layer.cornerRadius = BQRadius.medium
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.bqStroke1.cgColor
        
        let title = UILabel()
        title.text = "Aproveitamento do período"
        title.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        title.textColor = .bqText2
        
        let total = stats.completedCount + stats.expiredCount
        let bar = ProgressBarView()
        bar.configure(value: stats.completedCount, total: total, tone: .points)
        
        let caption = UILabel()
        caption.text = "\(stats.completedCount) de \(total) ocorrências concluídas · \(stats.expiredCount) expiradas"
        caption.font = BQFont.body(12)
        caption.textColor = .bqText3
        caption.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [title, bar, caption])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        
        return card
    }
    
    @objc private func handleBack() {
        onBack?()
    }
    
    @objc private func handleInvite() {
        onInvite?()
    }
}
