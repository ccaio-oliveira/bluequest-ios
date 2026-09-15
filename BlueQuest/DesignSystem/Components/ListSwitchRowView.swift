//
//  ListSwitchRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 15/09/26.
//

import Foundation
import UIKit

final class ListSwitchRowView: UIView {
    var onToggle: ((Bool) -> Void)?
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let toggle = UISwitch()
    
    init(icon: String) {
        super.init(frame: .zero)
        setupViews(icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, subtitle: String?, isOn: Bool, isEnabled: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        toggle.setOn(isOn, animated: true)
        toggle.isEnabled = isEnabled
    }
    
    private func setupViews(icon: String) {
        backgroundColor = .bqBg1
        
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .bqText2
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.font = BQFont.body(BQTypeScale.body, weight: .semibold)
        titleLabel.textColor = .bqText1
        titleLabel.lineBreakMode = .byTruncatingMiddle
        
        subtitleLabel.font = BQFont.body(12)
        subtitleLabel.textColor = .bqText3
        
        toggle.onTintColor = .bqBlue
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 1
        
        let stack = UIStackView(arrangedSubviews: [iconView, textStack, toggle])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.sp2),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.sp2)
        ])
    }
    
    @objc private func toggleChanged() {
        onToggle?(toggle.isOn)
    }
}
