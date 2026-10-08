//
//  PasswordResetViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 08/10/26.
//

import Foundation
import UIKit

final class PasswordResetViewController: UIViewController {
    var onBack: (() -> Void)?
    
    private let viewModel: PasswordResetViewModel
    
    private let subtitleLabel = UILabel()
    private let emailField = BQTextField(label: "E-mail", placeholder: "voce@email.com", icon: "envelope")
    private let sendButton = BQButton(title: "Enviar código", size: .lg)
    
    private let codeField = BQTextField(label: "Código", placeholder: "000000", icon: "number")
    private let passwordField = BQTextField(label: "Nova senha", placeholder: "Pelo menos 8 caracteres", icon: "lock", isSecure: true)
    private let confirmationField = BQTextField(label: "Confirmar nova senha", placeholder: "********", icon: "lock", isSecure: true)
    private let resetButton = BQButton(title: "Redefinir senha", size: .lg)
    private let resendButton = BQButton(title: "Reenviar código", variant: .ghost, size: .lg)
    private let anotherEmailButton = BQButton(title: "Usar outro e-mail", variant: .ghost, size: .lg)
    
    private let errorLabel = UILabel()
    private let emailStep = UIStackView()
    private let codeStep = UIStackView()
    
    init(viewModel: PasswordResetViewModel) {
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
        emailField.text = viewModel.email
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        render()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Redefinir senha"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleLabel])
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        subtitleLabel.font = BQFont.body(BQTypeScale.caption)
        subtitleLabel.textColor = .bqText2
        subtitleLabel.numberOfLines = 0
        
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.textContentType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        
        codeField.textField.keyboardType = .numberPad
        codeField.textField.textContentType = .oneTimeCode
        passwordField.textField.textContentType = .newPassword
        confirmationField.textField.textContentType = .newPassword
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(handleResend), for: .touchUpInside)
        anotherEmailButton.addTarget(self, action: #selector(handleAnotherEmail), for: .touchUpInside)
        
        errorLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        errorLabel.textColor = .bqRed
        errorLabel.numberOfLines = 0
        
        emailStep.axis = .vertical
        emailStep.spacing = BQSpacing.sp4
        [emailField, sendButton].forEach {
            emailStep.addArrangedSubview($0)
        }
        
        codeStep.axis = .vertical
        codeStep.spacing = BQSpacing.sp4
        [codeField, passwordField, confirmationField, resetButton, resendButton, anotherEmailButton].forEach {
            codeStep.addArrangedSubview($0)
        }
        codeStep.setCustomSpacing(BQSpacing.sp1, after: resetButton)
        codeStep.setCustomSpacing(0, after: resendButton)
        
        let stack = UIStackView(arrangedSubviews: [headerRow, subtitleLabel, errorLabel, emailStep, codeStep])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp5
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        
        view.keyboardLayoutGuide.usesBottomSafeArea = false
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp8),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            stack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
    }
    
    private func render() {
        let isCodeStep = viewModel.step == .code
        
        emailStep.isHidden = isCodeStep
        codeStep.isHidden = !isCodeStep
        
        subtitleLabel.text = isCodeStep ? "Se houver uma conta com \(viewModel.email), enviamos um código de 6 números para ele. O código vale por 15 minutos." : "Informe o e-mail da sua conta. Vamos mandar um código para você criar uma senha nova."
        
        errorLabel.text = viewModel.errorMessage
        errorLabel.isHidden = viewModel.errorMessage == nil
        
        sendButton.setLoading(viewModel.isLoading && !isCodeStep)
        resetButton.setLoading(viewModel.isLoading && isCodeStep)
        resendButton.isEnabled = !viewModel.isLoading
        anotherEmailButton.isEnabled = !viewModel.isLoading
    }
    
    @objc private func handleSend() {
        view.endEditing(true)
        Task { await viewModel.sendCode(to: emailField.text) }
    }
    
    @objc private func handleReset() {
        view.endEditing(true)
        
        Task {
            await viewModel.reset(code: codeField.text, password: passwordField.text, confirmation: confirmationField.text)
        }
    }
    
    @objc private func handleResend() {
        view.endEditing(true)
        Task { await viewModel.resendCode() }
    }
    
    @objc private func handleAnotherEmail() {
        codeField.text = ""
        viewModel.useAnotherEmail()
    }
    
    @objc private func handleBack() {
        onBack?()
    }
}
