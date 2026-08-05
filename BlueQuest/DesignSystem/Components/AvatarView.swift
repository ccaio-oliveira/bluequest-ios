//
//  AvatarView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 04/08/26.
//

import Foundation
import UIKit

final class AvatarView: UIView {
    private static let palette: [UIColor] = [.bqBlue, .bqAmber, .bqGreen, .bqAvatarPurple, .bqAvatarCyan]
    
    private let label = UILabel()
    private let diameter: CGFloat
    
    init(size: CGFloat = 26) {
        self.diameter = size
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: diameter, height: diameter)
    }
    
    func configure(name: String) {
        label.text = initials(from: name)
        backgroundColor = Self.palette[colorIndex(for: name)]
    }
    
    private func initials(from name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }
    
    private func colorIndex(for name: String) -> Int {
        let code = name.utf16.first.map(Int.init) ?? 0
        return code % Self.palette.count
    }
    
    private func setupViews() {
        layer.cornerRadius = diameter / 2
        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.bqBg1.cgColor
        
        label.font = BQFont.display(diameter * 0.4, weight: .bold)
        label.textColor = .bqOnBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
