//
//  AuthViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 12/08/26.
//

import Foundation
import UIKit

final class AuthViewController: UIViewController {
    var onAuthenticated: (() -> Void)?
    
    private let viewModel: AuthViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let segmented = SegmentedControlView(options: ["Entrar", "Criar conta"])
    private let nameField = BQTextField(label: "Nome", placeholder: "Como você aparece nos rankings", icon: "person")
    private let emailField = BQTextField(label: "E-mail", placeholder: "voce@email.com", icon: "envelope")
    private let passwordField = BQTextField(label: "Senha", placeholder: "••••••••", icon: "lock", isSecure: true)
    private let forgotLabel = UILabel()
    private let errorLabel = UILabel()
    private let submitButton = BQButton(title: "Entrar", size: .lg)
    private let googleButton = BQButton(title: "Continuar com Google", variant: .secondary, size: .lg)
    
    init(viewModel: AuthViewModel) {
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
        
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        
        viewModel.onAuthenticated = { [weak self] in
            self?.onAuthenticated?()
        }
        
        render()
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
        
        let logoLabel = UILabel()
        let logo = NSMutableAttributedString(
            string: "Blue",
            attributes: [
                .font: BQFont.display(34, weight: .bold),
                .foregroundColor: UIColor.bqText1
            ]
        )
        logo.append(NSAttributedString(
            string: "Quest",
            attributes: [
                .font: BQFont.display(34, weight: .bold),
                .foregroundColor: UIColor.bqBlueBright
            ]
        ))
        logoLabel.attributedText = logo
        logoLabel.textAlignment = .center
        
        let taglineLabel = UILabel()
        taglineLabel.text = "Desafios em grupo, pontos e ranking"
        taglineLabel.font = BQFont.body(14)
        taglineLabel.textColor = .bqText3
        taglineLabel.textAlignment = .center
        
        let headerStack = UIStackView(arrangedSubviews: [logoLabel, taglineLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 6
        
        segmented.onChange = { [weak self] index in
            self?.viewModel.setMode(index == 0 ? .signIn : .signUp)
        }
        
        forgotLabel.text = "Esqueci minha senha"
        forgotLabel.font = BQFont.body(BQTypeScale.caption, weight: .semibold)
        forgotLabel.textColor = .bqBlueBright
        
        errorLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        errorLabel.textColor = .bqRed
        errorLabel.numberOfLines = 0
        
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        googleButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        
        let footerLabel = UILabel()
        footerLabel.text = "Recebeu um convite? Entre com sua conta e ele será aplicado automaticamente."
        footerLabel.font = BQFont.body(12)
        footerLabel.textColor = .bqText3
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        
        [headerStack, segmented, nameField, emailField, passwordField, forgotLabel, errorLabel, submitButton, googleButton, footerLabel].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        contentStack.setCustomSpacing(28, after: headerStack)
        
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.textContentType = .emailAddress
        passwordField.textField.textContentType = .password
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: 56),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp6),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
    }
    
    private func render() {
        let isSignUp = viewModel.mode == .signUp
        
        nameField.isHidden = !isSignUp
        forgotLabel.isHidden = isSignUp
        
        errorLabel.text = viewModel.errorMessage
        errorLabel.isHidden = viewModel.errorMessage == nil
        
        submitButton.setTitle(viewModel.mode.actionTitle, for: .normal)
        submitButton.setLoading(viewModel.isLoading)
        
        googleButton.isEnabled = !viewModel.isLoading
    }
    
    private func observerKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @objc private func handleSubmit() {
        view.endEditing(true)
        
        Task {
            await viewModel.submit(name: nameField.text, email: emailField.text, password: passwordField.text)
        }
    }
    
    @objc private func handleGoogleSignIn() {
        view.endEditing(true)
        
        Task {
            await viewModel.signInWithGoogle(presenting: self)
        }
    }
}
