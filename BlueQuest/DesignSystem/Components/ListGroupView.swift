//
//  ListGroupView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 09/08/26.
//

import Foundation
import UIKit

final class ListGroupView: UIView {
    private let stack = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .bqStroke1
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        clipsToBounds = true
        
        stack.axis = .vertical
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRows(_ rows: [UIView]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rows.forEach { stack.addArrangedSubview($0) }
    }
}
