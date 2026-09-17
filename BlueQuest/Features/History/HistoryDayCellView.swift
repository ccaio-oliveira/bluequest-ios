//
//  HistoryDayCellView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class HistoryDayCellView: UIControl {
    var onTap: (() -> Void)?
    
    private let numberLabel = UILabel()
    private let detailLabel = UILabel()
    private let photoView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with cell: HistoryDayCell) {
        numberLabel.text = cell.dayNumber.map(String.init)
        numberLabel.textColor = textColor(for: cell.state)
        
        backgroundColor = background(for: cell.state)
        layer.borderWidth = cell.isToday ? 2 : 0
        layer.borderColor = UIColor.bqBlueBright.cgColor
        
        photoView.isHidden = !cell.hasPhoto
        
        switch cell.state {
        case .allDone, .partial where cell.points > 0:
            detailLabel.text = "+\(cell.points)"
            detailLabel.textColor = textColor(for: cell.state)
            detailLabel.isHidden = false
        case .missed:
            detailLabel.text = "x"
            detailLabel.textColor = .bqRed
            detailLabel.isHidden = false
        default:
            detailLabel.isHidden = true
        }
        
        isEnabled = cell.date != nil
    }
    
    private func setupViews() {
        layer.cornerRadius = BQRadius.small
        
        numberLabel.font = BQFont.display(13, weight: .semibold)
        numberLabel.textAlignment = .center
        
        detailLabel.font = BQFont.display(9, weight: .bold)
        detailLabel.textAlignment = .center
        
        photoView.image = UIImage(systemName: "photo.fill")
        photoView.tintColor = .bqText3
        photoView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 8, weight: .semibold)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [numberLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        addSubview(photoView)
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor),
            
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            photoView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            photoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3)
        ])
    }
    
    private func background(for state: HistoryDayState) -> UIColor {
        switch state {
        case .allDone: .bqGreenDim
        case .partial: .bqAmberDim
        default: .clear
        }
    }
    
    private func textColor(for state: HistoryDayState) -> UIColor {
        switch state {
        case .allDone: .bqGreen
        case .partial: .bqAmber
        case .missed: .bqRed
        case .future, .outside: .bqText3
        }
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
