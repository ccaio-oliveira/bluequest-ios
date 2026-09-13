//
//  BQTextArea.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 11/09/26.
//

import Foundation
import UIKit

final class BQTextArea: UIView {
    let textView = UITextView()
    
    private let placeholderLabel = UILabel()
    
    var text: String {
        get { textView.text }
        set {
            textView.text = newValue
            updatePlaceholder()
        }
    }
    
    init(label: String, placeholder: String) {
        super.init(frame: .zero)
        setupViews(label: label, placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(label: String, placeholder: String) {
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        titleLabel.textColor = .bqText2
        
        let box = UIView()
        box.backgroundColor = .bqBg1
        box.layer.cornerRadius = BQRadius.small
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.bqStroke1.cgColor
        
        let font = BQFont.body(BQTypeScale.body)
        
        textView.font = font
        textView.textColor = .bqText1
        textView.tintColor = .bqBlueBright
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = placeholder
        placeholderLabel.font = font
        placeholderLabel.textColor = .bqText3
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(textView)
        box.addSubview(placeholderLabel)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, box])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            textView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12),
            textView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            textView.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: ceil(font.lineHeight * 3)),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        updatePlaceholder()
    }
    
    private func updatePlaceholder() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension BQTextArea: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
    }
}
