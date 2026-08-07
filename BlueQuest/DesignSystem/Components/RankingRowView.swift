//
//  RankingRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class RankingRowView: UIView {
    private let positionLabel = UILabel()
    private let avatar = AvatarView(size: 36)
    private let nameLabel = UILabel()
    private let pointsLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with row: ChallengeRankingRow) {
        positionLabel.text = "\(row.position)"
        positionLabel.textColor = medalColor(for: row.position)
        
        avatar.configure(name: row.name)
        
        let name = NSMutableAttributedString(
            string: row.name,
            attributes: [
                .font: BQFont.body(BQTypeScale.body, weight: .semibold),
                .foregroundColor: UIColor.bqText1
            ]
        )
        
        if row.isYou {
            name.append(NSAttributedString(
                string: " · você",
                attributes: [
                    .font: BQFont.body(BQTypeScale.body, weight: .regular),
                    .foregroundColor: UIColor.bqBlueBright
                ]
            ))
        }
        
        nameLabel.attributedText = name
        
        let points = NSMutableAttributedString(
            string: "\(row.points)",
            attributes: [
                .font: BQFont.display(BQTypeScale.body, weight: .bold),
                .foregroundColor: UIColor.bqText1
            ]
        )
        
        points.append(NSAttributedString(
            string: " pts",
            attributes: [
                .font: BQFont.display(12, weight: .medium),
                .foregroundColor: UIColor.bqText3
            ]
        ))
        
        pointsLabel.attributedText = points
        
        backgroundColor = row.isYou ? .bqBlueDim : .clear
        layer.borderColor = (row.isYou ? UIColor.bqBlue : .clear).cgColor
    }
    
    private func medalColor(for position: Int) -> UIColor {
        switch position {
        case 1: .bqAmber
        case 2: .bqMedalSilver
        case 3: .bqMedalBronze
        default: .bqText3
        }
    }
    
    private func setupViews() {
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        
        positionLabel.font = BQFont.display(BQTypeScale.body, weight: .bold)
        positionLabel.textAlignment = .center
        
        pointsLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [positionLabel, avatar, nameLabel, pointsLabel])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            positionLabel.widthAnchor.constraint(equalToConstant: 28),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
