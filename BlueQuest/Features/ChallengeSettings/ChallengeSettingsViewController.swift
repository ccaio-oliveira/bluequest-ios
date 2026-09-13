//
//  ChallengeSettingsViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 12/09/26.
//

import Foundation
import UIKit

final class ChallengeSettingsViewController: UIViewController {
    var onBack: (() -> Void)?
    
    private let viewModel: ChallengeSettingsViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let detailsSection = UIStackView()
    
    private let challengeNameLabel = UILabel()
    private let nameField = BQTextField(label: "Nome", placeholder: "Nome do desafio")
    private let descriptionArea = BQTextArea(label: "Descrição", placeholder: "Nome do desafio")
    private let startField = BQDateField(label: "Início", icon: "calendar")
    private let endField = BQDateField(label: "Término", icon: "calendar.badge.clock")
    private let saveButton = BQButton(title: "Salvar alterações", icon: "square.and.arrow.down", variant: .secondary)
    private let saveErrorLabel = UILabel()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadErrorLabel = UILabel()
    private let retryButton = BQButton(title: "Tentar de novo", icon: "arrow.clockwise", variant: .secondary)
    private let loadErrorStack = UIStackView()
    private let toast = ToastView()
    
    private var hasFilledForm = false
    
    init(viewModel: ChallengeSettingsViewModel) {
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
        setupDismissKeyboardGesture()
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        viewModel.onSaved = { [weak self] in
            self?.showSavedToast()
        }
        
        render()
        
        Task { await viewModel.load() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        
        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(makeDetailsSection())
        
        loadingIndicator.color = .bqText3
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        loadErrorLabel.font = BQFont.body(BQTypeScale.body)
        loadErrorLabel.textColor = .bqText2
        loadErrorLabel.textAlignment = .center
        loadErrorLabel.numberOfLines = 0
        
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        loadErrorStack.axis = .vertical
        loadErrorStack.spacing = BQSpacing.sp4
        loadErrorStack.alignment = .center
        loadErrorStack.addArrangedSubview(loadErrorLabel)
        loadErrorStack.addArrangedSubview(retryButton)
        loadErrorStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadErrorStack)
        
        toast.isHidden = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        
        view.keyboardLayoutGuide.usesBottomSafeArea = false
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp8),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadErrorStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadErrorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            loadErrorStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding),

            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }
    
    private func makeHeader() -> UIView {
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Configurações"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        challengeNameLabel.font = BQFont.body(BQTypeScale.caption)
        challengeNameLabel.textColor = .bqText3
        challengeNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let creatorBadge = BadgeView()
        creatorBadge.configure(text: "você é o criador", tone: .available, systemIcon: "star.fill")
        
        let subtitleRow = UIStackView(arrangedSubviews: [challengeNameLabel, creatorBadge, UIView()])
        subtitleRow.axis = .horizontal
        subtitleRow.spacing = 6
        subtitleRow.alignment = .center
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleRow])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleStack])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        return headerRow
    }
    
    private func makeDetailsSection() -> UIView {
        let datesRow = UIStackView(arrangedSubviews: [startField, endField])
        datesRow.axis = .horizontal
        datesRow.spacing = 10
        datesRow.distribution = .fillEqually
        
        let hintLabel = UILabel()
        hintLabel.text = "Alterar o período não recupera ocorrências já expiradas."
        hintLabel.font = BQFont.body(12)
        hintLabel.textColor = .bqText3
        hintLabel.numberOfLines = 0
        
        saveErrorLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        saveErrorLabel.textColor = .bqRed
        saveErrorLabel.numberOfLines = 0
        saveErrorLabel.isHidden = true
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        detailsSection.axis = .vertical
        detailsSection.spacing = BQSpacing.sp3
        detailsSection.isHidden = true
        
        [OverlineLabel("Desafio"), nameField, descriptionArea, datesRow, hintLabel, saveErrorLabel, saveButton].forEach {
            detailsSection.addArrangedSubview($0)
        }
        
        return detailsSection
    }
    
    private func render() {
        challengeNameLabel.text = viewModel.challengeName
        
        if viewModel.isLoading && viewModel.form == nil {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        loadErrorLabel.text = viewModel.loadError
        loadErrorStack.isHidden = viewModel.loadError == nil
        
        if let form = viewModel.form, !hasFilledForm {
            fill(form)
            hasFilledForm = true
        }
        
        detailsSection.isHidden = viewModel.form == nil
        
        saveErrorLabel.text = viewModel.saveError
        saveErrorLabel.isHidden = viewModel.saveError == nil
        saveButton.setLoading(viewModel.isSaving)
    }
    
    private func fill(_ form: ChallengeSettingsForm) {
        nameField.text = form.name
        descriptionArea.text = form.description
        startField.date = form.startDate
        endField.date = form.endDate
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if form.canEditStart {
            startField.minimumDate = today
        }
        
        if form.canEditDetails {
            endField.minimumDate = today
        }
        
        startField.isEnabled = form.canEditStart
        endField.isEnabled = form.canEditDetails
        nameField.textField.isEnabled = form.canEditDetails
        descriptionArea.textView.isEditable = form.canEditDetails
        saveButton.isHidden = !form.canEditDetails
    }
    
    private func showSavedToast() {
        toast.configure(text: "Alterações salvas", tone: .success, systemIcon: "checkmark")
        toast.alpha = 0
        toast.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.toast.alpha = 1
        }
        
        UIView.animate(withDuration: 0.2, delay: 1.5) {
            self.toast.alpha = 0
        } completion: { _ in
            self.toast.isHidden = true
        }
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleSave() {
        view.endEditing(true)
        
        let values = ChallengeSettingsValues(
            name: nameField.text,
            description: descriptionArea.text,
            startDate: startField.date,
            endDate: endField.date
        )
        
        Task { await viewModel.save(values) }
    }
    
    @objc private func handleRetry() {
        Task { await viewModel.load() }
    }
    
    @objc private func handleBack() {
        onBack?()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
