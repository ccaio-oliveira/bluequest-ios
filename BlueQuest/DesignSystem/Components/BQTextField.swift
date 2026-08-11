//
//  BQTextField.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation
import UIKit

final class BQTextField: UIView {
    let textField = UITextField()
    
    private let titleLabel = UILabel()
    private let iconView = UIImageView()
    
    init(label: String, placeholder: String, icon: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        setupViews(label: label, placeholder: placeholder, icon: icon, isSecure: isSecure)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var text: String {
        textField.text ?? ""
    }
    
    private func setupViews(label: String, placeholder: String, icon: String, isSecure: Bool) {
        titleLabel.text = label
        titleLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        titleLabel.textColor = .bqText2
        
        let box = UIView()
        box.backgroundColor = .bqBg1
        box.layer.cornerRadius = BQRadius.small
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.bqStroke1.cgColor
        
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .bqText3
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.bqText3]
        )
        textField.font = BQFont.body(BQTypeScale.body)
        textField.textColor = .bqText1
        textField.tintColor = .bqBlueBright
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let boxStack = UIStackView(arrangedSubviews: [iconView, textField])
        boxStack.axis = .horizontal
        boxStack.spacing = 10
        boxStack.alignment = .center
        boxStack.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(boxStack)
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, box])
        mainStack.axis = .vertical
        mainStack.spacing = 6
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(equalToConstant: 48),
            boxStack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            boxStack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14),
            boxStack.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
