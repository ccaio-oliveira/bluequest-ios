//
//  CreateChallengeViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/08/26.
//

import Foundation
import UIKit

final class CreateChallengeViewController: UIViewController {
    var onClose: (() -> Void)?
    var onCreated: (() -> Void)?
    
    private let viewModel: CreateChallengeViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let tasksStack = UIStackView()
    
    private let nameField = BQTextField(label: "Nome", placeholder: "Projeto Verão", icon: "flag.fill")
    private let descriptionField = BQTextField(label: "Descrição", placeholder: "Contexto do desafio", icon: "text.alignleft")
    private let startField = BQDateField(label: "Início", icon: "calendar")
    private let endField = BQDateField(label: "Término", icon: "calendar.badge.clock")
    private let addTaskButton = BQButton(title: "Adicionar tarefa", icon: "plus", variant: .secondary)
    private let submitButton = BQButton(title: "Criar desafio", size: .lg)
    private let errorLabel = UILabel()
    
    private var taskDrafts: [TaskFormValues] = []
    
    init(viewModel: CreateChallengeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg0
        
        setupLayout()
        observerKeyboard()
        setupDismissKeyboardGesture()
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        viewModel.onCreated = { [weak self] in
            self?.onCreated?()
        }
        
        render()
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        let closeButton = IconButtonView(icon: "xmark")
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Criar desafio"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        let headerRow = UIStackView(arrangedSubviews: [closeButton, titleLabel, UIView()])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        let datesRow = UIStackView(arrangedSubviews: [startField, endField])
        datesRow.axis = .horizontal
        datesRow.spacing = 10
        datesRow.distribution = .fillEqually
        
        let today = Date()
        startField.date = today
        endField.date = Calendar.current.date(byAdding: .day, value: 29, to: today) ?? today
        
        tasksStack.axis = .vertical
        tasksStack.spacing = BQSpacing.sp3
        
        addTaskButton.addTarget(self, action: #selector(handleAddTask), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        errorLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        errorLabel.textColor = .bqRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        [headerRow, nameField, descriptionField, datesRow, tasksStack, addTaskButton, errorLabel, submitButton].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp8),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
    }
    
    private func renderTasks() {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, draft) in taskDrafts.enumerated() {
            let row = TaskDraftRowView()
            
            row.configure(with: draft)
            
            row.onTap = { [weak self] in
                self?.presentTaskSheet(editingIndex: index)
            }
            
            row.onRemove = { [weak self] in
                self?.taskDrafts.remove(at: index)
                self?.renderTasks()
            }
            
            tasksStack.addArrangedSubview(row)
        }
    }
    
    private func presentTaskSheet(editingIndex: Int?) {
        let existing = editingIndex.map { taskDrafts[$0] }
        let range = startField.date <= endField.date ? startField.date...endField.date : nil
        let sheet = TaskFormSheetViewController(editing: existing, dateRange: range)
        
        sheet.onSave = { [weak self] values in
            guard let self else { return }
            
            if let editingIndex {
                self.taskDrafts[editingIndex] = values
            } else {
                self.taskDrafts.append(values)
            }
            
            self.renderTasks()
        }
        
        present(sheet, animated: true)
    }
    
    private func addTaskForm() {
        let form = TaskFormView()
        
        form.selectWeekdays(Set(1...7))
        tasksStack.addArrangedSubview(form)
    }
    
    private func render() {
        errorLabel.text = viewModel.errorMessage
        errorLabel.isHidden = viewModel.errorMessage == nil
        
        submitButton.setLoading(viewModel.isSaving)
        addTaskButton.isEnabled = !viewModel.isSaving
    }
    
    private func observerKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func keyboardWillChange(_ notification: Notification) {
        guard let frame = notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let overlap = view.bounds.maxY - view.convert(frame, from: nil).minY
        
        scrollView.contentInset.bottom = max(overlap, 0)
        scrollView.verticalScrollIndicatorInsets.bottom = max(overlap, 0)
    }
    
    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func handleAddTask() {
        presentTaskSheet(editingIndex: nil)
    }
    
    @objc private func handleClose() {
        onClose?()
    }
    
    @objc private func handleSubmit() {
        view.endEditing(true)
        
        let form = ChallengeFormValues(
            name: nameField.text,
            description: descriptionField.text,
            startDate: startField.date,
            endDate: endField.date,
            tasks: taskDrafts
        )
        
        Task {
            await viewModel.save(form)
        }
    }
}
