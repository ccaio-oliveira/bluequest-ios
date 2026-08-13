//
//  BQButton.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class BQButton: UIButton {
    enum Variant {
        case primary, secondary, ghost, danger
        
        var background: UIColor {
            switch self {
            case .primary: .bqBlue
            case .secondary: .bqBlueDim
            case .ghost: .clear
            case .danger: .bqRedDim
            }
        }
        
        var foreground: UIColor {
            switch self {
            case .primary: .bqOnBlue
            case .secondary: .bqBlueBright
            case .ghost: .bqBlueBright
            case .danger: .bqRed
            }
        }
    }
    
    enum Size {
        case lg, md, sm
        
        var height: CGFloat {
            switch self {
            case .lg: 52
            case .md: 44
            case .sm: 34
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .lg: 17
            case .md: 15
            case .sm: 13
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .lg: 24
            case .md: 18
            case .sm: 14
            }
        }
        
        var cornerRadius: CGFloat { self == .sm ? BQRadius.small : BQRadius.medium }
        var iconSize: CGFloat { self == .sm ? 16 : 20 }
    }
    
    init(title: String, icon: String? = nil, variant: Variant = .primary, size: Size = .md) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = variant.background
        config.baseForegroundColor = variant.foreground
        config.cornerStyle = .fixed
        config.background.cornerRadius = size.cornerRadius
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: size.horizontalPadding, bottom: 0, trailing: size.horizontalPadding)
        
        if let icon {
            config.image = UIImage(systemName: icon)
            config.imagePadding = BQSpacing.sp2
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: size.iconSize, weight: .semibold)
        }
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = BQFont.display(size.fontSize, weight: .semibold)
            return outgoing
        }
        
        configuration = config
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }
    
    func setLoading(_ isLoading: Bool) {
        configuration?.showsActivityIndicator = isLoading
        isEnabled = !isLoading
    }
}
