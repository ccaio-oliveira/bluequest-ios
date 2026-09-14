//
//  TaskFormSheetViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/09/26.
//

import Foundation
import UIKit

final class TaskFormSheetViewController: UIViewController {
    var onSave: ((TaskFormValues) -> Void)?
    var onDelete: (() -> Void)?
    
    private let formView = TaskFormView()
    private let saveButton = BQButton(title: "Salvar tarefa", size: .lg)
    private let errorLabel = UILabel()
    private let deleteButton = BQButton(title: "Excluir", icon: "trash", variant: .danger, size: .lg)
    private let hintLabel = UILabel()
    
    private let initialValues: TaskFormValues?
    private let formTitle: String
    private let hint: String?
    private let allowsDelete: Bool
    
    init(editing values: TaskFormValues?, hint: String? = nil, allowsDelete: Bool = false) {
        initialValues = values
        formTitle = values == nil ? "Nova tarefa" : "Editar tarefa"
        self.hint = hint
        self.allowsDelete = allowsDelete
        super.init(nibName: nil, bundle: nil)
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = BQRadius.large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg1
        
        errorLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        errorLabel.textColor = .bqRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        
        formView.setTitle(formTitle)
        
        hintLabel.text = hint
        hintLabel.font = BQFont.body(12)
        hintLabel.textColor = .bqText3
        hintLabel.numberOfLines = 0
        hintLabel.isHidden = hint == nil
        
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        
        let buttonsRow = UIStackView(arrangedSubviews: allowsDelete ? [deleteButton, saveButton] : [saveButton])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = BQSpacing.sp2
        
        let stack = UIStackView(arrangedSubviews: [formView, hintLabel, errorLabel, buttonsRow])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stack)
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: content.topAnchor),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp8),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            stack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
            
        ])
        
        if let initialValues {
            formView.configure(with: initialValues)
        } else {
            formView.selectWeekdays(Set(1...7))
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func validate(_ values: TaskFormValues) -> String? {
        if values.name.isEmpty {
            return "Dê um nome à tarefa."
        }
        
        if values.points < 1 {
            return "A tarefa precisa vale pelo menos 1 ponto."
        }
        
        if values.weekdays.isEmpty {
            return "Escolha pelo menos um dia."
        }
        
        return nil
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func handleSave() {
        view.endEditing(true)
        
        let values = formView.values()
        
        if let problem = validate(values) {
            errorLabel.text = problem
            errorLabel.isHidden = false
            return
        }
        
        onSave?(values)
        dismiss(animated: true)
    }
    
    @objc private func handleDelete() {
        let action = onDelete
        dismiss(animated: true) { action?() }
    }
}
