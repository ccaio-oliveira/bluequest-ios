//
//  ProgressBarView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 04/08/26.
//

import Foundation
import UIKit

final class ProgressBarView: UIView {
    private let fillView = UIView()
    private var fillWidthConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Tone {
        case primary, points
        
        var color: UIColor {
            switch self {
            case .primary: .bqBlueBright
            case .points: .bqAmber
            }
        }
    }
    
    func configure(value: Int, total: Int, tone: Tone = .primary) {
        fillView.backgroundColor = tone.color
        
        let progress = total > 0 ? min(max(CGFloat(value) / CGFloat(total), 0), 1) : 0
        
        fillWidthConstraint?.isActive = false
        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: progress)
        fillWidthConstraint?.isActive = true
    }
    
    private func setupViews() {
        backgroundColor = .bqStroke1
        layer.cornerRadius = 3
        clipsToBounds = true
        
        fillView.backgroundColor = .bqBlueBright
        fillView.layer.cornerRadius = 3
        fillView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(fillView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 6),
            fillView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fillView.topAnchor.constraint(equalTo: topAnchor),
            fillView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
