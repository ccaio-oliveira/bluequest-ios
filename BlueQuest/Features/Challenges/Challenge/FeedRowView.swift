//
//  FeedRowView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 18/09/26.
//

import Foundation
import UIKit

final class FeedRowView: UIControl {
    var onTap: (() -> Void)?
    
    private let thumbnailView = UIImageView()
    private let placeholderIcon = UIImageView()
    private let taskLabel = UILabel()
    private let pointsLabel = UILabel()
    private let avatar = AvatarView(size: 22)
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    
    private var imageTask: Task<Void, Never>?
    
    private static let thumbnailSide: CGFloat = 56
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .bqBg2 : .bqBg1
        }
    }
    
    func configure(with item: ChallengeFeedItem, timeText: String) {
        taskLabel.text = item.taskName
        pointsLabel.text = "+\(item.points) pts"
        timeLabel.text = timeText
        avatar.configure(name: item.name)
        
        let name = NSMutableAttributedString(
            string: item.name,
            attributes: [.foregroundColor: UIColor.bqText2]
        )
        
        if item.isYou {
            name.append(NSAttributedString(
                string: " · você",
                attributes: [.foregroundColor: UIColor.bqBlueBright]
            ))
        }
        
        nameLabel.attributedText = name
        
        imageTask?.cancel()
        thumbnailView.image = nil
        isEnabled = item.photoUrl != nil
        
        guard let url = item.photoUrl else {
            thumbnailView.backgroundColor = .bqGreenDim
            placeholderIcon.isHidden = false
            return
        }
        
        thumbnailView.backgroundColor = .bqBg2
        placeholderIcon.isHidden = true
        
        let side = Self.thumbnailSide * traitCollection.displayScale
        
        imageTask = Task { [weak self] in
            let image = await ImageLoader.shared.image(for: url, thumbnailSize: CGSize(width: side, height: side))
            
            guard !Task.isCancelled else { return }
            self?.thumbnailView.image = image
        }
    }
    
    private func setupViews() {
        backgroundColor = .bqBg1
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = BQRadius.small
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderIcon.image = UIImage(systemName: "checkmark")
        placeholderIcon.tintColor = .bqGreen
        placeholderIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        placeholderIcon.translatesAutoresizingMaskIntoConstraints = false
        
        thumbnailView.addSubview(placeholderIcon)
        
        taskLabel.font = BQFont.body(BQTypeScale.body, weight: .semibold)
        taskLabel.textColor = .bqText1
        
        pointsLabel.font = BQFont.display(12, weight: .bold)
        pointsLabel.textColor = .bqAmber
        pointsLabel.setContentHuggingPriority(.required, for: .horizontal)
        pointsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nameLabel.font = BQFont.body(BQTypeScale.caption)
        
        timeLabel.font = BQFont.body(12)
        timeLabel.textColor = .bqText3
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let taskRow = UIStackView(arrangedSubviews: [taskLabel, pointsLabel])
        taskRow.axis = .horizontal
        taskRow.spacing = BQSpacing.sp2
        taskRow.alignment = .firstBaseline
        
        let personRow = UIStackView(arrangedSubviews: [avatar, nameLabel, UIView(), timeLabel])
        personRow.axis = .horizontal
        personRow.spacing = 6
        personRow.alignment = .center
        
        let textStack = UIStackView(arrangedSubviews: [taskRow, personRow])
        textStack.axis = .vertical
        textStack.spacing = 6
        
        let stack = UIStackView(arrangedSubviews: [thumbnailView, textStack])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp3
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            thumbnailView.widthAnchor.constraint(equalToConstant: Self.thumbnailSide),
            thumbnailView.heightAnchor.constraint(equalToConstant: Self.thumbnailSide),
            
            placeholderIcon.centerXAnchor.constraint(equalTo: thumbnailView.centerXAnchor),
            placeholderIcon.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor),
            
            stack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.sp3),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.sp3),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.sp3),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.cardPadding)
        ])
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
