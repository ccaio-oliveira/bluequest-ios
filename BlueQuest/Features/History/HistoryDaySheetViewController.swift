//
//  HistoryDaySheetViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class HistoryDaySheetViewController: UIViewController {
    private let day: HistoryDay
    private let dayTitle: String
    
    init(day: HistoryDay, title: String) {
        self.day = day
        self.dayTitle = title
        super.init(nibName: nil, bundle: nil)
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = BQRadius.large
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg1
        
        let titleLabel = UILabel()
        titleLabel.text = dayTitle
        titleLabel.font = BQFont.display(16, weight: .semibold)
        titleLabel.textColor = .bqText1
        
        let pointsBadge = BadgeView()
        pointsBadge.configure(text: "+\(day.points) pts no dia", tone: .points, systemIcon: "bolt.fill")
        pointsBadge.isHidden = day.points == 0
        
        let tasksBadge = BadgeView()
        tasksBadge.configure(text: "\(day.completed) de \(day.total) \(day.total == 1 ? "tarefa" : "tarefas")", tone: day.expired > 0 ? .expired : .done, systemIcon: nil)
        
        let badgesRow = UIStackView(arrangedSubviews: [pointsBadge, tasksBadge, UIView()])
        badgesRow.axis = .horizontal
        badgesRow.spacing = BQSpacing.sp2
        badgesRow.alignment = .center
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, badgesRow])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp3
        stack.setCustomSpacing(BQSpacing.sp4, after: badgesRow)
        
        makeTaskViews().forEach { stack.addArrangedSubview($0) }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: content.topAnchor),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp8),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            stack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
    }
    
    private func makeTaskViews() -> [UIView] {
        var views: [UIView] = []
        
        let challenges = day.tasks.map(\.challengeName)
        var seen: Set<String> = []
        
        for challenge in challenges where seen.insert(challenge).inserted {
            let label = UILabel()
            label.text = challenge
            label.font = BQFont.body(12, weight: .semibold)
            label.textColor = .bqText3
            views.append(label)
            
            let tasks = day.tasks
                .filter { $0.challengeName == challenge }
                .sorted { lhs, _ in lhs.state == .completed }
            
            for task in tasks {
                let card = TaskCardView()
                card.configure(with: TaskCardModel(
                    taskName: task.name,
                    points: task.points,
                    state: task.state,
                    deadlineText: task.deadlineText,
                    hasPhoto: task.hasPhoto
                ))
                
                views.append(card)
            }
        }
        
        return views
    }
}
