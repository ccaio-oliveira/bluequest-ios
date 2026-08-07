//
//  PointsPillView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class PointsPillView: UIView {
    enum Size {
        case md, lg
        
        var height: CGFloat { self == .lg ? 40 : 28 }
        var fontSize:CGFloat { self == .lg ? 18 : 14 }
        var horizontalPadding: CGFloat { self == .lg ? 16 : 12 }
        var iconSize: CGFloat { self == .lg ? 20 : 16 }
    }
    
    private let iconView = UIImageView()
    private let label = UILabel()
    private let size: Size
    
    init(size: Size = .md) {
        self.size = size
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let width = size.horizontalPadding * 2 + iconView.intrinsicContentSize.width + 5 + label.intrinsicContentSize.width
        
        return CGSize(width: width, height: size.height)
    }
    
    func configure(points: Int) {
        label.text = "+\(points) pts"
        invalidateIntrinsicContentSize()
    }
    
    private func setupViews() {
        backgroundColor = .bqAmber
        layer.cornerRadius = size.height / 2
        clipsToBounds = true
        
        iconView.image = UIImage(systemName: "bolt.fill")
        iconView.tintColor = .bqOnAmber
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: size.iconSize, weight: .bold)
        iconView.contentMode = .scaleAspectFit
        
        label.font = BQFont.display(size.fontSize, weight: .bold)
        label.textColor = .bqOnAmber
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: size.height),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: size.horizontalPadding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -size.horizontalPadding),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
