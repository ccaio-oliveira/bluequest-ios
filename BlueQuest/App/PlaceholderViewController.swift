//
//  PlaceholderViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

final class PlaceholderViewController: UIViewController {
    private let emptyIcon: String
    private let emptyTitle: String
    private let emptyMessage: String
    
    init(icon: String, title: String, message: String) {
        emptyIcon = icon
        emptyTitle = title
        emptyMessage = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg0
        
        let empty = EmptyStateView(icon: emptyIcon, title: emptyTitle, message: emptyMessage)
        empty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(empty)
        
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
