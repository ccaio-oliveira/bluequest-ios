//
//  ParticipantRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 09/08/26.
//

import Foundation
import UIKit

final class ParticipantRowView: UIView {
    private let avatar = AvatarView(size: 38)
    private let nameLabel = UILabel()
    private let creatorBadge = BadgeView()
    private let joinedLabel = UILabel()
    private let pointsLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with row: ChallengeParticipantRow) {
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
                string: " você",
                attributes: [
                    .font: BQFont.body(BQTypeScale.caption, weight: .regular),
                    .foregroundColor: UIColor.bqBlueBright
                ]
            ))
        }
        
        nameLabel.attributedText = name
        
        creatorBadge.isHidden = !row.isCreator
        
        if row.isCreator {
            creatorBadge.configure(text: "criador", tone: .available, systemIcon: "star.fill")
        }
        
        joinedLabel.text = "entrou em \(row.joinedText)"
        
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
    }
    
    private func setupViews() {
        backgroundColor = .bqBg1
        
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let nameRow = UIStackView(arrangedSubviews: [nameLabel, creatorBadge, UIView()])
        nameRow.axis = .horizontal
        nameRow.spacing = 6
        nameRow.alignment = .center
        
        joinedLabel.font = BQFont.body(12)
        joinedLabel.textColor = .bqText3
        
        let textStack = UIStackView(arrangedSubviews: [nameRow, joinedLabel])
        textStack.axis = .vertical
        textStack.spacing = 1
        
        pointsLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [avatar, textStack, pointsLabel])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.sp2),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.sp2)
        ])
    }
}
