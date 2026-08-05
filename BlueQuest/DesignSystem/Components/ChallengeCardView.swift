//
//  ChallengeCardView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 04/08/26.
//

import Foundation
import UIKit

final class ChallengeCardView: UIView {
    var onTap: (() -> Void)?
    
    private let nameLabel = UILabel()
    private let periodLabel = UILabel()
    private let statusBadge = BadgeView()
    private let progressBar = ProgressBarView()
    private let dayLabel = UILabel()
    private let pointsLabel = UILabel()
    private let avatarsStack = UIStackView()
    private let participantsLabel = UILabel()
    
    private lazy var progressSection = UIStackView()
    private lazy var participantsRow = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with row: HomeChallengeRow) {
        nameLabel.font = BQFont.display(row.isHero ? BQTypeScale.title2 : BQTypeScale.headline, weight: .bold)
        nameLabel.text = row.name
        periodLabel.text = row.periodText
        
        layer.cornerRadius = row.isHero ? BQRadius.large : BQRadius.medium
        alpha = row.state == .closed ? 0.7 : 1
        
        if row.isHero {
            layer.borderColor = UIColor.bqBlue.withAlphaComponent(0.4).cgColor
            layer.shadowColor = UIColor.bqBlue.cgColor
            layer.shadowOpacity = 0.35
            layer.shadowRadius = 10
            layer.shadowOffset = CGSize(width: 0, height: 4)
        } else {
            layer.borderColor = UIColor.bqStroke1.cgColor
            layer.shadowOpacity = 0
        }
        
        switch row.state {
        case .closed:
            statusBadge.isHidden = false
            statusBadge.configure(text: "Encerrado", tone: .neutral, systemIcon: nil)
        case .future:
            statusBadge.isHidden = false
            statusBadge.configure(text: "Em breve", tone: .neutral, systemIcon: nil)
        case .inProgress:
            if let rank = row.rank {
                statusBadge.isHidden = false
                statusBadge.configure(text: "\(rank)º", tone: .points, systemIcon: "trophy.fill")
            } else {
                statusBadge.isHidden = true
            }
        }
        
        progressSection.isHidden = (row.state == .future)
        progressBar.configure(value: row.day, total: row.totalDays)
        
        dayLabel.text = "Dia \(row.day) de \(row.totalDays)"
        pointsLabel.text = "\(row.points) pts"
        
        avatarsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for name in row.participantNames.prefix(4) {
            let avatar = AvatarView(size: 26)
            avatar.configure(name: name)
            avatarsStack.addArrangedSubview(avatar)
        }
        
        participantsLabel.text = "\(row.participantNames.count) participantes"
        participantsRow.isHidden = row.participantNames.isEmpty
    }
    
    private func setupViews() {
        backgroundColor = .bqBg1
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        nameLabel.textColor = .bqText1
        nameLabel.numberOfLines = 0
        
        periodLabel.font = BQFont.body(BQTypeScale.caption)
        periodLabel.textColor = .bqText3
        
        let titleStack = UIStackView(arrangedSubviews: [nameLabel, periodLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        
        let topRow = UIStackView(arrangedSubviews: [titleStack, UIView(), statusBadge])
        topRow.axis = .horizontal
        topRow.spacing = BQSpacing.sp3
        topRow.alignment = .top
        
        dayLabel.font = BQFont.body(12)
        dayLabel.textColor = .bqText3
        
        pointsLabel.font = BQFont.display(12, weight: .bold)
        pointsLabel.textColor = .bqAmber
        pointsLabel.textAlignment = .right
        
        let progressMeta = UIStackView(arrangedSubviews: [dayLabel, UIView(), pointsLabel])
        progressMeta.axis = .horizontal
        
        progressSection = UIStackView(arrangedSubviews: [progressBar, progressMeta])
        progressSection.axis = .vertical
        progressSection.spacing = 6
        
        avatarsStack.axis = .horizontal
        avatarsStack.spacing = -8
        
        participantsLabel.font = BQFont.body(12)
        participantsLabel.textColor = .bqText3
        
        participantsRow = UIStackView(arrangedSubviews: [avatarsStack, participantsLabel, UIView()])
        participantsRow.axis = .horizontal
        participantsRow.spacing = BQSpacing.sp2
        participantsRow.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [topRow, progressSection, participantsRow])
        mainStack.axis = .vertical
        mainStack.spacing = BQSpacing.sp3
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.cardPadding),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.cardPadding),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.cardPadding),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.cardPadding)
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
