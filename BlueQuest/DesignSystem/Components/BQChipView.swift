//
//  BQChipView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation
import UIKit

final class BQChipView: UIControl {
    private let label = UILabel()
    
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 28, height: 34)
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        label.text = title
        label.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        layer.cornerRadius = 17
        layer.borderWidth = 1
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 34),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateAppearance()
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAppearance() {
        backgroundColor = isSelected ? .bqBlue : .bqBg2
        label.textColor = isSelected ? .bqOnBlue : .bqText2
        layer.borderColor = (isSelected ? UIColor.bqBlue : UIColor.bqStroke1).cgColor
    }
}
