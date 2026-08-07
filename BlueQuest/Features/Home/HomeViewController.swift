//
//  HomeViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let tasksStack = UIStackView()
    private let headerView = HomeHeaderView()
    private let challengesSectionLabel = UILabel()
    private let challengesStack = UIStackView()
    private let createButton = BQButton(title: "Criar desafio", icon: "plus", variant: .primary, size: .lg)
    private let pointsPill = PointsPillView(size: .lg)
    
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
        renderTasks()
        
        viewModel.onChange = { [weak self] in
            self?.renderTasks()
        }
        
        viewModel.onPointsAwarded = { [weak self] points in
            self?.showPointsPop(points: points)
        }
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
    }
    
    private func renderTasks() {
        headerView.configure(with: viewModel.header)
        challengesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for row in viewModel.rows {
            let card = TaskCardView()
            card.configure(with: row)
            card.onComplete = { [weak self] in
                self?.viewModel.completeTask(occurrenceID: row.occurrenceID)
            }
            tasksStack.addArrangedSubview(card)
        }
        
        for challenge in viewModel.challenges {
            let card = ChallengeCardView()
            card.configure(with: challenge)
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
}
