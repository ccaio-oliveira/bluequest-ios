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
    private let inputField = PickerInputField()
    private let valueLabel = UILabel()
    private let box = UIView()
    private let formatter = DateFormatter()
    
    var date: Date {
        get { picker.date }
        set {
            picker.date = newValue
            updateValueLabel()
        }
    }
    
    var minimumDate: Date? {
        get { picker.minimumDate }
        set {
            picker.minimumDate = newValue
            updateValueLabel()
        }
    }
    
    var isEnabled = true {
        didSet {
            inputField.isEnabled = isEnabled
            alpha = isEnabled ? 1 : 0.5
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
        
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "pt_BR")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        inputField.inputView = picker
        inputField.inputAccessoryView = makeToolbar()
        inputField.tintColor = .clear
        inputField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        inputField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(boxStack)
        box.addSubview(inputField)
        
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

            inputField.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            inputField.topAnchor.constraint(equalTo: box.topAnchor),
            inputField.bottomAnchor.constraint(equalTo: box.bottomAnchor),

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
    
    private func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.tintColor = .bqBlueBright
        toolbar.items = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(handleDone))
        ]
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc private func dateChanged() {
        updateValueLabel()
    }
    
    @objc private func editingDidBegin() {
        box.layer.borderColor = UIColor.bqBlue.cgColor
    }
    
    @objc private func editingDidEnd() {
        box.layer.borderColor = UIColor.bqStroke1.cgColor
    }
    
    @objc private func handleDone() {
        inputField.resignFirstResponder()
    }
}

private final class PickerInputField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
}
