//
//  HomeHeaderView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 04/08/26.
//

import Foundation
import UIKit

final class HomeHeaderView: UIView {
    var onNotificationsTap: (() -> Void)?
    
    private let overlineLabel = UILabel()
    private let pointsLabel = UILabel()
    private let notificationsButton = UIButton(type: .system)
    private let ring = ProgressRingView(size: 60)
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with header: HomeHeader) {
        overlineLabel.attributedText = NSAttributedString(string: header.dateText.uppercased(), attributes: [.kern: BQTypeScale.micro * 0.08])
        
        let points = NSMutableAttributedString(
            string: "\(header.points)",
            attributes: [
                .font: BQFont.display(BQTypeScale.title1, weight: .bold),
                .foregroundColor: UIColor.bqText1
            ]
        )
        
        points.append(NSAttributedString(
            string: " pts",
            attributes: [
                .font: BQFont.display(20, weight: .bold),
                .foregroundColor: UIColor.bqAmber
            ]
        ))
        pointsLabel.attributedText = points
        
        ring.configure(
            value: header.completedCount,
            total: header.doableCount,
            text: "\(header.completedCount)/\(header.doableCount)"
        )
    }
    
    private func setupViews() {
        overlineLabel.font = BQFont.body(BQTypeScale.micro, weight: .semibold)
        overlineLabel.textColor = .bqText3
        
        let textStack = UIStackView(arrangedSubviews: [overlineLabel, pointsLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        
        notificationsButton.setImage(UIImage(systemName: "bell"), for: .normal)
        notificationsButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular), forImageIn: .normal)
        notificationsButton.tintColor = .bqText2
        notificationsButton.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)
        notificationsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let rightStack = UIStackView(arrangedSubviews: [notificationsButton, ring])
        rightStack.axis = .horizontal
        rightStack.spacing = 10
        rightStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [textStack, UIView(), rightStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            notificationsButton.widthAnchor.constraint(equalToConstant: BQSpacing.hitTarget),
            notificationsButton.heightAnchor.constraint(equalToConstant: BQSpacing.hitTarget),
            
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func handleNotifications() {
        onNotificationsTap?()
    }
}
