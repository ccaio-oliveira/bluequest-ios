//
//  StatTileView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 09/08/26.
//

import Foundation
import UIKit

final class StatTileView: UIView {
    enum Tone {
        case neutral, points, primary
        
        var valueColor: UIColor {
            switch self {
            case .neutral: .bqText1
            case .points: .bqAmber
            case .primary: .bqBlueBright
            }
        }
    }
    
    init(icon: String, value: String, label: String, tone: Tone = .neutral) {
        super.init(frame: .zero)
        
        backgroundColor = .bqBg1
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        iconView.tintColor = .bqText3
        iconView.contentMode = .left
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = BQFont.display(24, weight: .bold)
        valueLabel.textColor = tone.valueColor
        
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = BQFont.body(12)
        labelLabel.textColor = .bqText3
        labelLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [iconView, valueLabel, labelLabel])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp1
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
