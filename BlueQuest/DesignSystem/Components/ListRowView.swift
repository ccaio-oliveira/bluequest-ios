//
//  ListRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

final class ListRowView: UIControl {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronView = UIImageView()
    
    init(icon: String, title: String, subtitle: String? = nil, showsChevron: Bool = true, trailingIcon: String = "chevron.right", isDestructive: Bool = false) {
        super.init(frame: .zero)
        setupViews(icon: icon, title: title, subtitle: subtitle, showsChevron: showsChevron, trailingIcon: trailingIcon, isDestructive: isDestructive)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .bqBg2 : .bqBg1
        }
    }
    
    private func setupViews(icon: String, title: String, subtitle: String?, showsChevron: Bool, trailingIcon: String, isDestructive: Bool) {
        backgroundColor = .bqBg1
        
        let tint: UIColor = isDestructive ? .bqRed : .bqText2
        
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = tint
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.text = title
        titleLabel.font = BQFont.body(BQTypeScale.body, weight: .semibold)
        titleLabel.textColor = isDestructive ? .bqRed : .bqText1
        
        subtitleLabel.text = subtitle
        subtitleLabel.font = BQFont.body(12)
        subtitleLabel.textColor = .bqText3
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isHidden = subtitle == nil
        
        chevronView.image = UIImage(systemName: trailingIcon)
        chevronView.tintColor = .bqText3
        chevronView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronView.contentMode = .scaleAspectFit
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        chevronView.isHidden = !showsChevron
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 1
        
        let stack = UIStackView(arrangedSubviews: [iconView, textStack, chevronView])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp3
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.sp2),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.sp2)
        ])
    }
}
