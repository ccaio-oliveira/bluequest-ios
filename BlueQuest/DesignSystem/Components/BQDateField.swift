//
//  BQDateField.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation
import UIKit

final class BQDateField: UIView {
    private let picker = UIDatePicker()
    private let valueLabel = UILabel()
    private let formatter = DateFormatter()
    
    var date: Date {
        get { picker.date }
        set {
            picker.date = newValue
            updateValueLabel()
        }
    }
    
    init(label: String, icon: String, mode: UIDatePicker.Mode = .date) {
        super.init(frame: .zero)
        setupViews(label: label, icon: icon, mode: mode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(label: String, icon: String, mode: UIDatePicker.Mode) {
        formatter.locale = Locale(identifier: "pt_BR")
        
        if mode == .time {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        } else {
            formatter.dateFormat = "d MMM yyyy"
        }
        
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        titleLabel.textColor = .bqText2
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        valueLabel.font = BQFont.body(BQTypeScale.body)
        valueLabel.textColor = .bqText1
        
        let box = UIView()
        box.backgroundColor = .bqBg1
        box.layer.cornerRadius = BQRadius.small
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.bqStroke1.cgColor
        
        let boxStack = UIStackView(arrangedSubviews: [iconView, valueLabel, UIView()])
        boxStack.axis = .horizontal
        boxStack.spacing = 10
        boxStack.alignment = .center
        boxStack.isUserInteractionEnabled = false
        boxStack.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(boxStack)
        
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "pt_BR")
        picker.alpha = 0.02
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(picker)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, box])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(equalToConstant: 48),
            
            boxStack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            boxStack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14),
            boxStack.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            
            picker.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            picker.topAnchor.constraint(equalTo: box.topAnchor),
            picker.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateValueLabel()
    }
    
    private func updateValueLabel() {
        valueLabel.text = formatter.string(from: picker.date).replacingOccurrences(of: ".", with: "")
    }
    
    @objc private func dateChanged() {
        updateValueLabel()
    }
}
