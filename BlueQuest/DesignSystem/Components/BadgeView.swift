//
//  BadgeView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 28/07/26.
//

import Foundation
import UIKit

final class BadgeView: UIView {
    enum Tone {
        case points, done, expired, available, neutral
        
        var background: UIColor {
            switch self {
            case .points: .bqAmberDim
            case .done: .bqGreenDim
            case .expired: .bqRedDim
            case .available: .bqBlueDim
            case .neutral: .bqBg2
            }
        }
        
        var foreground: UIColor {
            switch self {
            case .points: .bqAmber
            case .done: .bqGreen
            case .expired: .bqRed
            case .available: .bqBlueBright
            case .neutral: .bqText2
            }
        }
    }
    
    private let iconView = UIImageView()
    private let label = UILabel()
    
    override var intrinsicContentSize: CGSize {
        var width: CGFloat = 20
        
        if !iconView.isHidden {
            width += iconView.intrinsicContentSize.width + BQSpacing.sp1
        }
        
        width += label.intrinsicContentSize.width
        return CGSize(width: width, height: 24)
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, tone: Tone, systemIcon: String?) {
        label.text = text
        label.textColor = tone.foreground
        backgroundColor = tone.background
        
        if let systemIcon {
            iconView.image = UIImage(systemName: systemIcon)
            iconView.tintColor = tone.foreground
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
        
        invalidateIntrinsicContentSize()
    }
    
    private func setupViews() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        label.font = BQFont.display(12, weight: .semibold)
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp1
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
