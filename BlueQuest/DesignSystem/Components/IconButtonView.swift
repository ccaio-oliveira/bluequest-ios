//
//  IconButtonView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class IconButtonView: UIButton {
    enum Variant {
        case neutral, primary, ghost
        
        var background: UIColor {
            switch self {
            case .neutral: .bqBg2
            case .primary: .bqBlue
            case .ghost: .clear
            }
        }
        
        var foreground: UIColor {
            switch self {
            case .neutral: .bqText2
            case .primary: .bqOnBlue
            case .ghost: .bqText2
            }
        }
    }
    
    init(icon: String, variant: Variant = .neutral, size: CGFloat = BQSpacing.hitTarget) {
        super.init(frame: .zero)
        
        setImage(UIImage(systemName: icon), for: .normal)
        setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: size * 0.42, weight: .medium), forImageIn: .normal)
        tintColor = variant.foreground
        backgroundColor = variant.background
        layer.cornerRadius = size / 2
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
