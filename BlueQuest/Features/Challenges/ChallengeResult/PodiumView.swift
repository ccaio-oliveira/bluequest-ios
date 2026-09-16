//
//  PodiumView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 16/09/26.
//

import Foundation
import UIKit

final class PodiumView: UIView {
    private let columnsStack = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with entries: [PodiumEntry]) {
        columnsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for index in [1, 0, 2] where entries.indices.contains(index) {
            columnsStack.addArrangedSubview(makeColumn(for: entries[index]))
        }
    }
    
    private func setupViews() {
        backgroundColor = .bqBg1
        layer.cornerRadius = BQRadius.large
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        layer.shadowColor = UIColor.bqBlue.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        let overline = OverlineLabel("Ranking final")
        overline.textAlignment = .center
        
        columnsStack.axis = .horizontal
        columnsStack.alignment = .bottom
        columnsStack.distribution = .fillEqually
        columnsStack.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [overline, columnsStack])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.sp5),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.cardPadding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.cardPadding),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func makeColumn(for entry: PodiumEntry) -> UIView {
        let color = UIColor.bqMedal(for: entry.position)
        
        let avatar = AvatarView(size: 44)
        avatar.configure(name: entry.name)
        
        let nameLabel = UILabel()
        nameLabel.text = entry.name
        nameLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        nameLabel.textColor = .bqText1
        nameLabel.textAlignment = .center
        
        let pointsLabel = UILabel()
        pointsLabel.text = "\(entry.points) pts"
        pointsLabel.font = BQFont.display(BQTypeScale.caption, weight: .bold)
        pointsLabel.textColor = color
        
        let block = UIView()
        block.backgroundColor = .bqBg2
        block.layer.cornerRadius = BQRadius.small
        block.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        block.clipsToBounds = true
        
        let topBorder = UIView()
        topBorder.backgroundColor = color
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        block.addSubview(topBorder)
        
        let positionLabel = UILabel()
        positionLabel.text = "\(entry.position)"
        positionLabel.font = BQFont.display(18, weight: .bold)
        positionLabel.textColor = color
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        block.addSubview(positionLabel)
        
        let column = UIStackView(arrangedSubviews: [avatar, nameLabel, pointsLabel, block])
        column.axis = .vertical
        column.spacing = 6
        column.alignment = .center
        
        NSLayoutConstraint.activate([
            block.widthAnchor.constraint(equalTo: column.widthAnchor),
            block.heightAnchor.constraint(equalToConstant: Self.blockHeight(for: entry.position)),
            
            topBorder.topAnchor.constraint(equalTo: block.topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: block.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: block.trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 3),
            
            positionLabel.topAnchor.constraint(equalTo: topBorder.bottomAnchor, constant: 6),
            positionLabel.centerXAnchor.constraint(equalTo: block.centerXAnchor)
        ])
        
        return column
    }
    
    private static func blockHeight(for position: Int) -> CGFloat {
        switch position {
        case 1: 88
        case 2: 64
        default: 48
        }
    }
}
