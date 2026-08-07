//
//  SegmentControlView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/08/26.
//

import Foundation
import UIKit

final class SegmentedControlView: UIView {
    var onChange: ((Int) -> Void)?
    
    private(set) var selectedIndex = 0
    
    private var buttons: [UIButton] = []
    
    init(options: [String]) {
        super.init(frame: .zero)
        setupViews(options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select(_ index: Int) {
        selectedIndex = index
        updateAppearance()
    }
    
    private func setupViews(options: [String]) {
        backgroundColor = .bqBg1
        
        layer.cornerRadius = BQRadius.small
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
            buttons.append(button)
            
            stack.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            stack.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        for (index, button) in buttons.enumerated() {
            let isActive = (index == selectedIndex)
            
            button.backgroundColor = isActive ? .bqBg2 : .clear
            button.setTitleColor(isActive ? .bqText1 : .bqText3, for: .normal)
        }
    }
    
    @objc private func handleTap(_ sender: UIButton) {
        select(sender.tag)
        onChange?(sender.tag)
    }
}
