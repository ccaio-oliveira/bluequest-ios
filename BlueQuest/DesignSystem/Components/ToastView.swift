//
//  ToastView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation
import UIKit

final class ToastView: UIView {
    enum Tone {
        case neutral, success, error
        
        var iconColor: UIColor {
            switch self {
            case .neutral: .bqBlueBright
            case .success: .bqGreen
            case .error: .bqRed
            }
        }
    }
    
    private let iconView = UIImageView()
    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, tone: Tone, systemIcon: String?) {
        label.text = text
        
        if let systemIcon {
            iconView.image = UIImage(systemName: systemIcon)
            iconView.tintColor = tone.iconColor
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
    }
    
    private func setupViews() {
        backgroundColor = .bqBg2
        layer.cornerRadius = 21
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.45
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 12)
        
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        label.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        label.textColor = .bqText1
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 42),
            
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
