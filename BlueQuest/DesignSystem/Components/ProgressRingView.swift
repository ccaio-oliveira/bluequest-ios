//
//  ProgressRingView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 04/08/26.
//

import Foundation
import UIKit

final class ProgressRingView: UIView {
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let label = UILabel()
    
    private let ringSize: CGFloat
    private let lineWidth: CGFloat
    
    init(size: CGFloat = 60, lineWidth: CGFloat = 6) {
        self.ringSize = size
        self.lineWidth = lineWidth
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: ringSize, height: ringSize)
    }
    
    func configure(value: Int, total: Int, text: String) {
        let progress = total > 0 ? min(max(CGFloat(value) / CGFloat(total), 0), 1) : 0
        
        progressLayer.strokeEnd = progress
        label.text = text
    }
    
    private func setupViews() {
        for shape in [trackLayer, progressLayer] {
            shape.fillColor = UIColor.clear.cgColor
            shape.lineWidth = lineWidth
            layer.addSublayer(shape)
        }
        
        trackLayer.strokeColor = UIColor.bqStroke1.cgColor
        progressLayer.strokeColor = UIColor.bqBlueBright.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        
        label.font = BQFont.display(ringSize * 0.24, weight: .bold)
        label.textColor = .bqText1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: ringSize),
            heightAnchor.constraint(equalToConstant: ringSize),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        
        trackLayer.frame = bounds
        trackLayer.path = path.cgPath
        progressLayer.frame = bounds
        progressLayer.path = path.cgPath
    }
}
