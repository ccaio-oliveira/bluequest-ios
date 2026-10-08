//
//  AccountViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/10/26.
//

import Foundation
import UIKit

final class AccountViewController: UIViewController {
    var onBack: (() -> Void)?
    
    private let viewModel: AccountViewModel
    
    private let scrollView = UIScrollView()
    private let nameField = BQTextField(label: "Nome", placeholder: "Seu nome", icon: "person")
    private let emailField = BQTextField(label: "E-mail", placeholder: "voce@gmail.com", icon: "envelope")
    private let emailHint = UILabel()
    private let emailPasswordField = BQTextField(label: "Senha atual", placeholder: "Para confirmar a troca de e-mail", icon: "lock", isSecure: true)
    private let saveDetailsButton = BQButton(title: "Salvar dados", size: .lg)
    
    private let passwordTitle = OverlineLabel("Senha")
    private let currentPasswordField = BQTextField(label: "Senha atual", placeholder: "Digite sua senha", icon: "lock", isSecure: true)
    private let newPasswordField = BQTextField(label: "Nova senha", placeholder: "Pelo menos 8 caracteres", icon: "lock", isSecure: true)
    private let confirmPasswordField = BQTextField(label: "Confirmar nova senha", placeholder: "********", icon: "lock", isSecure: true)
    private let savePasswordButton = BQButton(title: "Alterar senha", variant: .secondary, size: .lg)
    
    private let toast = ToastView()
    
    init(viewModel: AccountViewModel) {
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
        
        nameField.text = viewModel.user?.name ?? ""
        emailField.text = viewModel.user?.email ?? ""
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        viewModel.onSaved = { [weak self] message in
            self?.showToast(message, tone: .success)
        }
        
        viewModel.onError = { [weak self] message in
            self?.showToast(message, tone: .error)
        }
        
        render()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupLayout() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        emailField.textField.addTarget(self, action: #selector(emailDidChange), for: .editingChanged)
        
        emailHint.font = BQFont.body(12)
        emailHint.textColor = .bqText3
        emailHint.numberOfLines = 0
        emailHint.text = "Sua conta entra pelo Google. Crie uma senha abaixo para poder trocar o e-mail."
        
        newPasswordField.textField.textContentType = .newPassword
        confirmPasswordField.textField.textContentType = .newPassword
        
        saveDetailsButton.addTarget(self, action: #selector(handleSaveDetails), for: .touchUpInside)
        savePasswordButton.addTarget(self, action: #selector(handleSavePassword), for: .touchUpInside)
        
        let detailsStack = UIStackView(arrangedSubviews: [OverlineLabel("Dados"), nameField, emailField, emailHint, emailPasswordField, saveDetailsButton])
        detailsStack.axis = .vertical
        detailsStack.spacing = BQSpacing.sp3
        
        let passwordStack = UIStackView(arrangedSubviews: [passwordTitle, currentPasswordField, newPasswordField, confirmPasswordField, savePasswordButton])
        passwordStack.axis = .vertical
        passwordStack.spacing = BQSpacing.sp3
        
        let contentStack = UIStackView(arrangedSubviews: [makeHeader(), detailsStack, passwordStack])
        contentStack.axis = .vertical
        contentStack.spacing = BQSpacing.sp8
        contentStack.setCustomSpacing(BQSpacing.sp5, after: contentStack.arrangedSubviews[0])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStack)
        
        toast.isHidden = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        
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
            
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }
    
    private func makeHeader() -> UIView {
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Conta"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleLabel])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        return headerRow
    }
    
    private func render() {
        let hasPassword = viewModel.hasPassword
        let operation = viewModel.savingOperation
        
        emailField.textField.isEnabled = hasPassword
        emailField.alpha = hasPassword ? 1 : 0.5
        emailHint.isHidden = hasPassword
        emailPasswordField.isHidden = !(hasPassword && viewModel.emailChanged(emailField.text))
        
        passwordTitle.setText(hasPassword ? "Alterar senha" : "Criar senha")
        currentPasswordField.isHidden = !hasPassword
        savePasswordButton.setTitle(hasPassword ? "Alterar senha" : "Criar senha", for: .normal)
        
        saveDetailsButton.setLoading(operation == .details)
        savePasswordButton.setLoading(operation == .password)
        saveDetailsButton.isEnabled = operation == nil
        savePasswordButton.isEnabled = operation == nil
    }
    
    private func showToast(_ message: String, tone: ToastView.Tone) {
        let isError = tone == .error
        
        toast.configure(text: message, tone: tone, systemIcon: isError ? "exclamationmark.triangle.fill" : "checkmark")
        toast.alpha = 0
        toast.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.toast.alpha = 1
        }
        
        UIView.animate(withDuration: 0.2, delay: isError ? 2.5 : 1.5) {
            self.toast.alpha = 0
        } completion: { _ in
            self.toast.isHidden = true
        }
    }
    
    @objc private func emailDidChange() {
        render()
    }
    
    @objc private func handleSaveDetails() {
        view.endEditing(true)
        
        Task {
            let saved = await viewModel.saveDetails(name: nameField.text, email: emailField.text, currentPassword: emailPasswordField.text)
            
            if saved {
                emailPasswordField.text = ""
                render()
            }
        }
    }
    
    @objc private func handleSavePassword() {
        view.endEditing(true)
        
        Task {
            let saved = await viewModel.savePassword(current: currentPasswordField.text, new: newPasswordField.text, confirmation: confirmPasswordField.text)
            
            if saved {
                [currentPasswordField, newPasswordField, confirmPasswordField].forEach { $0.text = "" }
            }
        }
    }
    
    @objc private func handleBack() {
        onBack?()
    }
}
