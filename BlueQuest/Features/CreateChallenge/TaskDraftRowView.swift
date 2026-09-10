//
//  TaskDraftRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

extension TaskFormValues {
    var recurrenceSummary: String {
        if weekdays.count == 7 {
            return "Todos os dias"
        }
        
        let names = [1: "dom", 2: "seg", 3: "ter", 4: "qua", 5: "qui", 6: "sex", 7: "sab"]
        
        return weekdays.sorted().compactMap { names[$0] }.joined(separator: "/")
    }
}

final class TaskDraftRowView: UIView {
    var onTap: (() -> Void)?
    var onRemove: (() -> Void)?
    
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let pointsBadge = BadgeView()
    private let removeButton = IconButtonView(icon: "trash", variant: .ghost, size: 32)
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with values: TaskFormValues) {
        nameLabel.text = values.name
        metaLabel.text = "\(values.recurrenceSummary) · até \(Self.timeFormatter.string(from: values.deadline))"
        pointsBadge.configure(text: "+\(values.points) pts", tone: .points, systemIcon: "bolt.fill")
    }
    
    private func setupViews() {
        backgroundColor = .bqBg1
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        nameLabel.font = BQFont.body(BQTypeScale.body, weight: .semibold)
        nameLabel.textColor = .bqText1
        nameLabel.numberOfLines = 0
        
        metaLabel.font = BQFont.body(BQTypeScale.caption)
        metaLabel.textColor = .bqText3
        
        removeButton.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let stack = UIStackView(arrangedSubviews: [textStack, pointsBadge, removeButton])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.cardPadding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.cardPadding),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    @objc private func handleRemove() {
        onRemove?()
    }
}
