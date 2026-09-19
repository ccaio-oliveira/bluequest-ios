//
//  BannerView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class BannerView: UIView {
    enum Tone {
        case offline, error, info
        
        var background: UIColor {
            switch self {
            case .offline: .bqBg2
            case .error: .bqRedDim
            case .info: .bqBlueDim
            }
        }
        
        var foreground: UIColor {
            switch self {
            case .offline: .bqText2
            case .error: .bqRed
            case .info: .bqBlueBright
            }
        }
        
        var icon: String {
            switch self {
            case .offline: "icloud.slash"
            case .error: "exclamationmark.triangle.fill"
            case .info: "info.circle.fill"
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
    
    func configure(text: String, tone: Tone, systemIcon: String? = nil) {
        label.text = text
        label.textColor = tone.foreground
        
        iconView.image = UIImage(systemName: systemIcon ?? tone.icon)
        iconView.tintColor = tone.foreground
        
        backgroundColor = tone.background
    }
    
    private func setupViews() {
        layer.cornerRadius = BQRadius.small
        
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        label.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        label.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
    }
}
