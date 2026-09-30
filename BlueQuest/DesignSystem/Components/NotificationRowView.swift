//
//  NotificationRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 30/09/26.
//

import Foundation
import UIKit

enum NotificationKind: String {
    case joined, ranking, ended, reminder, deadline, invite
    
    var icon: String {
        switch self {
        case .joined: "person.badge.plus"
        case .ranking: "trophy"
        case .ended: "flag"
        case .reminder: "checkmark.circle"
        case .deadline: "clock"
        case .invite: "envelope"
        }
    }
    
    var tint: UIColor {
        switch self {
        case .ranking, .deadline: .bqAmber
        default: .bqBlueBright
        }
    }
}


struct NotificationRowModel: Equatable {
    let kind: NotificationKind
    let title: String
    let message: String
    let timeText: String
    let isUnread: Bool
}

final class NotificationRowView: UIView {
    var onTap: (() -> Void)?
    
    private let iconCircle = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()
    private let unreadDot = UIView()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: NotificationRowModel) {
        iconView.image = UIImage(systemName: model.kind.icon)
        iconView.tintColor = model.kind.tint
        titleLabel.text = model.title
        timeLabel.text = model.timeText
        messageLabel.text = model.message
        unreadDot.isHidden = !model.isUnread
        backgroundColor = model.isUnread ? .bqBlueDim : .bqBg1
    }
    
    private func setupViews() {
        iconCircle.backgroundColor = .bqBg2
        iconCircle.layer.cornerRadius = 19
        
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)
        
        titleLabel.font = BQFont.body(14, weight: .semibold)
        titleLabel.textColor = .bqText1
        titleLabel.numberOfLines = 0
        
        timeLabel.font = BQFont.body(11)
        timeLabel.textColor = .bqText3
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        messageLabel.font = BQFont.body(13)
        messageLabel.textColor = .bqText2
        messageLabel.numberOfLines = 0
        
        unreadDot.backgroundColor = .bqBlueBright
        unreadDot.layer.cornerRadius = 4
        
        let titleRow = UIStackView(arrangedSubviews: [titleLabel, timeLabel])
        titleRow.spacing = BQSpacing.sp2
        titleRow.alignment = .firstBaseline
        
        let textStack = UIStackView(arrangedSubviews: [titleRow, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let stack = UIStackView(arrangedSubviews: [iconCircle, textStack, unreadDot])
        stack.spacing = BQSpacing.sp3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconCircle.widthAnchor.constraint(equalToConstant: 38),
            iconCircle.heightAnchor.constraint(equalToConstant: 38),
            
            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            
            unreadDot.widthAnchor.constraint(equalToConstant: 8),
            unreadDot.heightAnchor.constraint(equalToConstant: 8),
            
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
