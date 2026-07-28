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
        title = "Hoje"
        
        setupLayout()
        renderTasks()
        
        viewModel.onChange = { [weak self] in
            self?.renderTasks()
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
        
        tasksStack.axis = .vertical
        tasksStack.spacing = BQSpacing.sp2
        contentStack.addArrangedSubview(tasksStack)
        
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
    
    private func renderTasks() {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for row in viewModel.rows {
            let card = TaskCardView()
            card.configure(with: row)
            card.onComplete = { [weak self] in
                self?.viewModel.completeTask(occurrenceID: row.occurrenceID)
            }
            tasksStack.addArrangedSubview(card)
        }
    }
}
