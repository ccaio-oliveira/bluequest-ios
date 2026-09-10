//
//  TaskFormView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation
import UIKit

struct TaskFormValues {
    let name: String
    let points: Int
    let weekdays: Set<Int>
    let deadline: Date
    let allowsPhoto: Bool
}

final class TaskFormView: UIView {
    var onPointsChange: (() -> Void)?
    
    private let nameField = BQTextField(label: "", placeholder: "Fazer treino", icon: "checkmark.circle")
    private let pointsField = BQTextField(label: "Pontos", placeholder: "5", icon: "bolt.fill")
    private let deadlineField = BQDateField(label: "Prazo", icon: "clock", mode: .time)
    private let photoSwitch = UISwitch()
    private let pointsBadge = BadgeView()
    
    private var chips: [BQChipView] = []
    
    private static let weekdayTitles = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"]
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func values() -> TaskFormValues {
        let selected = chips.enumerated()
            .filter { $0.element.isSelected }
            .map { $0.offset + 1 }
        
        return TaskFormValues(
            name: nameField.text.trimmingCharacters(in: .whitespacesAndNewlines),
            points: Int(pointsField.text) ?? 0,
            weekdays: Set(selected),
            deadline: deadlineField.date,
            allowsPhoto: photoSwitch.isOn
        )
    }
    
    func selectWeekdays(_ days: Set<Int>) {
        for (index, chip) in chips.enumerated() {
            chip.isSelected = days.contains(index + 1)
        }
    }
    
    func configure(with values: TaskFormValues) {
        nameField.textField.text = values.name
        pointsField.textField.text = "\(values.points)"
        deadlineField.date = values.deadline
        photoSwitch.isOn = values.allowsPhoto
        selectWeekdays(values.weekdays)
        updatePointsBadge()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        let title = UILabel()
        title.text = "Nova tarefa"
        title.font = BQFont.display(16, weight: .semibold)
        title.textColor = .bqText1
        
        let headerRow = UIStackView(arrangedSubviews: [title, UIView(), pointsBadge])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp2
        headerRow.alignment = .center
        
        pointsField.textField.keyboardType = .numberPad
        pointsField.textField.addTarget(self, action: #selector(handlePointsChanged), for: .editingChanged)
        
        let recurrenceLabel = UILabel()
        recurrenceLabel.text = "Recorrência"
        recurrenceLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        recurrenceLabel.textColor = .bqText2
        
        let firstRow = UIStackView()
        firstRow.axis = .horizontal
        firstRow.spacing = 6
        firstRow.distribution = .fill
        
        let secondRow = UIStackView()
        secondRow.axis = .horizontal
        secondRow.spacing = 6
        secondRow.distribution = .fill
        
        for (index, title) in Self.weekdayTitles.enumerated() {
            let chip = BQChipView(title: title)
            chip.addTarget(self, action: #selector(handleChipTap(_:)), for: .touchUpInside)
            chips.append(chip)
            (index < 4 ? firstRow : secondRow).addArrangedSubview(chip)
        }
        
        firstRow.addArrangedSubview(UIView())
        secondRow.addArrangedSubview(UIView())
        
        let chipsGrid = UIStackView(arrangedSubviews: [firstRow, secondRow])
        chipsGrid.axis = .vertical
        chipsGrid.spacing = 6
        
        let recurrenceStack = UIStackView(arrangedSubviews: [recurrenceLabel, chipsGrid])
        recurrenceStack.axis = .vertical
        recurrenceStack.spacing = BQSpacing.sp2
        
        photoSwitch.onTintColor = .bqBlue
        photoSwitch.setContentHuggingPriority(.required, for: .horizontal)
        
        let photoLabel = UILabel()
        photoLabel.text = "Permitir foto"
        photoLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        photoLabel.textColor = .bqText2
        
        let photoStack = UIStackView(arrangedSubviews: [photoLabel, photoSwitch])
        photoStack.axis = .vertical
        photoStack.spacing = 6
        photoStack.alignment = .leading
        
        let bottomRow = UIStackView(arrangedSubviews: [deadlineField, photoStack])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 10
        bottomRow.alignment = .top
        
        let mainStack = UIStackView(arrangedSubviews: [headerRow, nameField, pointsField, recurrenceStack, bottomRow])
        mainStack.axis = .vertical
        mainStack.spacing = 14
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            deadlineField.widthAnchor.constraint(equalTo: bottomRow.widthAnchor, multiplier: 0.55),
            
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.cardPadding),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.cardPadding),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.cardPadding),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.cardPadding)
        ])
        
        updatePointsBadge()
    }
    
    private func updatePointsBadge() {
        let points = Int(pointsField.text) ?? 0
        pointsBadge.configure(text: "+\(points) pts", tone: .points, systemIcon: "bolt.fill")
    }
    
    @objc private func handleChipTap(_ chip: BQChipView) {
        chip.isSelected.toggle()
    }
    
    @objc private func handlePointsChanged() {
        updatePointsBadge()
        onPointsChange?()
    }
}
