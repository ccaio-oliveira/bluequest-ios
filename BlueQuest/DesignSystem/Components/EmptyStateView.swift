//
//  EmptyStateView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation
import UIKit

final class EmptyStateView: UIView {
    var onAction: (() -> Void)?
    
    private let actionButton: BQButton?
    
    init(icon: String, title: String, message: String, actionTitle: String? = nil, actionIcon: String? = nil) {
        actionButton = actionTitle.map {
            BQButton(title: $0, icon: actionIcon, variant: .primary, size: .md)
        }
        
        super.init(frame: .zero)
        setupViews(icon: icon, title: title, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(icon: String, title: String, message: String) {
        let iconCircle = UIView()
        iconCircle.backgroundColor = .bqBlueDim
        iconCircle.layer.cornerRadius = 32
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .bqBlueBright
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = BQFont.display(BQTypeScale.headline, weight: .semibold)
        titleLabel.textColor = .bqText1
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        let messageLabel = UILabel()
        messageLabel.attributedText = Self.paragraph(message)
        messageLabel.textColor = .bqText3
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [iconCircle, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp2
        stack.alignment = .center
        stack.setCustomSpacing(12, after: iconCircle)
        
        if let actionButton {
            actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
            stack.addArrangedSubview(actionButton)
            stack.setCustomSpacing(BQSpacing.sp5, after: messageLabel)
        }
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconCircle.widthAnchor.constraint(equalToConstant: 64),
            iconCircle.heightAnchor.constraint(equalToConstant: 64),
            
            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 206),
            
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.sp6),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.sp6),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.sp10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.sp10)
        ])
    }
    
    private static func paragraph(_ text: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineHeightMultiple = 1.45
        
        return NSAttributedString(
            string: text,
            attributes: [
                .font: BQFont.body(14),
                .paragraphStyle: style
            ]
        )
    }
    
    @objc private func handleAction() {
        onAction?()
    }
}
