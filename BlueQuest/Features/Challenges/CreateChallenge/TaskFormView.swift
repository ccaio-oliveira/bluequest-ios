//
//  TaskFormView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation
import UIKit

enum TaskRecurrenceMode: Int {
    case weekly = 0
    case dates = 1
}

struct TaskFormValues {
    let name: String
    let points: Int
    let mode: TaskRecurrenceMode
    let weekdays: Set<Int>
    let dates: [String]
    let deadline: Date
    let requiresPhoto: Bool
}

extension NewTask {
    init(from values: TaskFormValues) {
        let isEveryDay = values.weekdays.count == 7
        let isDates = values.mode == .dates
        
        self.init(
            name: values.name,
            points: values.points,
            recurrenceType: isDates ? "dates" : (isEveryDay ? "daily" : "weekdays"),
            weekdays: isDates || isEveryDay ? nil : values.weekdays.sorted(),
            dates: isDates ? values.dates : nil,
            deadlineTime: CalendarDayFormatter.timeString(from: values.deadline),
            photoRequirement: values.requiresPhoto ? "required" : "none"
        )
    }
}

final class TaskFormView: UIView {
    var onPointsChange: (() -> Void)?
    
    var dateRange: ClosedRange<Date>? {
        didSet { applyDateRange() }
    }
    
    private let titleLabel = UILabel()
    private let nameField = BQTextField(label: "", placeholder: "Fazer treino", icon: "checkmark.circle")
    private let pointsField = BQTextField(label: "Pontos", placeholder: "5", icon: "bolt.fill")
    private let deadlineField = BQDateField(label: "Prazo", icon: "clock", mode: .time)
    private let photoSwitch = UISwitch()
    private let pointsBadge = BadgeView()
    
    private let modeControl = SegmentedControlView(options: ["Toda semana", "Datas específicas"])
    private let chipsGrid = UIStackView()
    private let datesSection = UIStackView()
    private let datesList = UIStackView()
    private let newDateField = BQDateField(label: "Data", icon: "calendar")
    private let addDateButton = BQButton(title: "Adicionar data", icon: "plus", variant: .secondary)
    
    private var chips: [BQChipView] = []
    private var dates: [String] = []
    
    private static let weekdayTitles = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"]
    
    private static let dateDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter
    }()
    
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
            mode: TaskRecurrenceMode(rawValue: modeControl.selectedIndex) ?? .weekly,
            weekdays: Set(selected),
            dates: dates,
            deadline: deadlineField.date,
            requiresPhoto: photoSwitch.isOn
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
        photoSwitch.isOn = values.requiresPhoto
        selectWeekdays(values.weekdays)
        
        dates = values.dates
        modeControl.select(values.mode.rawValue)
        
        updateMode()
        renderDates()
        updatePointsBadge()
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        titleLabel.text = "Nova tarefa"
        titleLabel.font = BQFont.display(16, weight: .semibold)
        titleLabel.textColor = .bqText1
        
        let headerRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), pointsBadge])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp2
        headerRow.alignment = .center
        
        pointsField.textField.keyboardType = .numberPad
        pointsField.textField.addTarget(self, action: #selector(handlePointsChanged), for: .editingChanged)
        
        let recurrenceLabel = UILabel()
        recurrenceLabel.text = "Recorrência"
        recurrenceLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        recurrenceLabel.textColor = .bqText2
        
        modeControl.onChange = { [weak self] _ in
            self?.updateMode()
        }
        
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
        
        chipsGrid.axis = .vertical
        chipsGrid.spacing = 6
        [firstRow, secondRow].forEach { chipsGrid.addArrangedSubview($0) }
        
        datesList.axis = .vertical
        datesList.spacing = BQSpacing.sp2
        
        addDateButton.addTarget(self, action: #selector(handleAddDate), for: .touchUpInside)
        
        datesSection.axis = .vertical
        datesSection.spacing = BQSpacing.sp3
        [datesList, newDateField, addDateButton].forEach { datesSection.addArrangedSubview($0) }
        datesSection.isHidden = true
        
        let recurrenceStack = UIStackView(arrangedSubviews: [recurrenceLabel, modeControl, chipsGrid, datesSection])
        recurrenceStack.axis = .vertical
        recurrenceStack.spacing = BQSpacing.sp2
        recurrenceStack.setCustomSpacing(BQSpacing.sp3, after: modeControl)
        
        photoSwitch.onTintColor = .bqBlue
        photoSwitch.setContentHuggingPriority(.required, for: .horizontal)
        
        let photoLabel = UILabel()
        photoLabel.text = "Exigir foto"
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
            
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: BQSpacing.cardPadding),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -BQSpacing.cardPadding)
        ])
        
        renderDates()
        updatePointsBadge()
    }
    
    private func updateMode() {
        let isWeekly = modeControl.selectedIndex == TaskRecurrenceMode.weekly.rawValue
        
        chipsGrid.isHidden = !isWeekly
        datesSection.isHidden = isWeekly
    }
    
    private func applyDateRange() {
        guard let dateRange else { return }
        
        newDateField.minimumDate = dateRange.lowerBound
        
        if newDateField.date < dateRange.lowerBound {
            newDateField.date = dateRange.lowerBound
        }
    }
    
    private func renderDates() {
        datesList.arrangedSubviews.forEach { $0.removeFromSuperview() }
        datesList.isHidden = dates.isEmpty
        
        for day in dates {
            let row = TaskDateRowView(text: Self.displayText(for: day))
            
            row.onRemove = { [weak self] in
                guard let self else { return }
                
                self.dates.removeAll { $0 == day }
                self.renderDates()
            }
            
            datesList.addArrangedSubview(row)
        }
    }
    
    private static func displayText(for day: String) -> String {
        guard let date = CalendarDayFormatter.localDate(from: day) else { return day }
        
        return dateDisplay.string(from: date).replacingOccurrences(of: ".", with: "")
    }
    
    private func updatePointsBadge() {
        let points = Int(pointsField.text) ?? 0
        pointsBadge.configure(text: "+\(points) pts", tone: .points, systemIcon: "bolt.fill")
    }
    
    @objc private func handleAddDate() {
        let day = CalendarDayFormatter.dayString(from: newDateField.date)
        
        guard !dates.contains(day) else { return }
        
        dates.append(day)
        dates.sort()
        renderDates()
    }
    
    @objc private func handleChipTap(_ chip: BQChipView) {
        chip.isSelected.toggle()
    }
    
    @objc private func handlePointsChanged() {
        updatePointsBadge()
        onPointsChange?()
    }
}

private final class TaskDateRowView: UIView {
    var onRemove: (() -> Void)?
    
    init(text: String) {
        super.init(frame: .zero)
        setupViews(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(text: String) {
        backgroundColor = .bqBg1
        layer.cornerRadius = BQRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.bqStroke1.cgColor
        
        let label = UILabel()
        label.text = text
        label.font = BQFont.body(BQTypeScale.body)
        label.textColor = .bqText1
        
        let removeButton = IconButtonView(icon: "trash", variant: .ghost, size: 32)
        removeButton.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, UIView(), removeButton])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BQSpacing.sp3),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BQSpacing.sp2),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    @objc private func handleRemove() {
        onRemove?()
    }
}
