//
//  TaskCardView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 28/07/26.
//

import Foundation
import UIKit

final class TaskCardView: UIView {
    var onComplete: (() -> Void)?
    
    private let actionButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let photoIcon = UIImageView()
    private let badge = BadgeView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with row: HomeTaskRow) {
        let state = row.state
        
        titleLabel.attributedText = NSAttributedString(string: row.taskName, attributes: state == .completed ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.bqText3] : [:])
        
        metaLabel.text = metaText(for: row)
        metaLabel.textColor = state == .expired ? .bqRed : .bqText3
        photoIcon.isHidden = !row.hasPhoto
        photoIcon.tintColor = metaLabel.textColor
        
        actionButton.setImage(UIImage(systemName: iconName(for: state)), for: .normal)
        actionButton.tintColor = iconColor(for: state)
        actionButton.backgroundColor = circleBackground(for: state)
        actionButton.layer.borderColor = (state == .available ? UIColor.bqBlueBright : .clear).cgColor
        actionButton.isUserInteractionEnabled = (state == .available)
        
        badge.configure(text: "+\(row.points) pts", tone: state == .completed ? .points : .neutral, systemIcon: "bolt.fill")
        
        layer.borderColor = (state == .available ? UIColor.bqStroke2 : UIColor.bqStroke1).cgColor
        alpha = (state == .available) ? 1.0 : 0.6
    }
    
    private func metaText(for row: HomeTaskRow) -> String {
        switch row.state {
        case .expired: "Expirou às \(row.deadlineText)"
        case .completed: "Concluída"
        case .future: "Disponível em breve"
        case .available: "Disponível até \(row.deadlineText)"
        }
    }
    
    private func iconName(for state: OccurrenceState) -> String {
        switch state {
        case .completed: "checkmark"
        case .expired: "xmark"
        case .future: "clock"
        case .available: "circle"
        }
    }
    
    private func iconColor(for state: OccurrenceState) -> UIColor {
        switch state {
        case .completed: .bqGreen
        case .expired: .bqRed
        case .available: .bqBlueBright
        case .future: .bqText3
        }
    }
    
    private func circleBackground(for state: OccurrenceState) -> UIColor {
        switch state {
        case .completed: .bqGreenDim
        case .expired: .bqRedDim
        default: .bqBg2
        }
    }
    
    private func setupViews() {
        backgroundColor = .bqBg1
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        
        actionButton.layer.cornerRadius = 22
        actionButton.layer.borderWidth = 2
        actionButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold), forImageIn: .normal)
        actionButton.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = BQFont.body(16, weight: .semibold)
        titleLabel.textColor = .bqText1
        titleLabel.numberOfLines = 0
        
        metaLabel.font = BQFont.body(BQTypeScale.caption)
        metaLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        photoIcon.image = UIImage(systemName: "camera.fill")
        photoIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        photoIcon.contentMode = .scaleAspectFit
        photoIcon.setContentHuggingPriority(.required, for: .horizontal)
        
        let metaRow = UIStackView(arrangedSubviews: [metaLabel, photoIcon, UIView()])
        metaRow.axis = .horizontal
        metaRow.spacing = 6
        metaRow.alignment = .center
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaRow])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let mainStack = UIStackView(arrangedSubviews: [actionButton, textStack, badge])
        mainStack.axis = .horizontal
        mainStack.spacing = 14
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            actionButton.widthAnchor.constraint(equalToConstant: 44),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    @objc private func handleComplete() {
        onComplete?()
    }
}
