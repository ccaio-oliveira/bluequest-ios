//
//  InviteSheetViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation
import UIKit

final class InviteSheetViewController: UIViewController {
    var onPreviewInvite: (() -> Void)?
    
    private let inviteURL: String
    private let toast = ToastView()
    
    init(inviteURL: String) {
        self.inviteURL = inviteURL
        super.init(nibName: nil, bundle: nil)
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in 300 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = BQRadius.large
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bqBg1
        setupViews()
    }
    
    private func setupViews() {
        let title = UILabel()
        title.text = "Convidar para o desafio"
        title.font = BQFont.display(19, weight: .bold)
        title.textColor = .bqText1
        
        let description = UILabel()
        description.text = "Quem receber o link entra direto no Projeto Verão. Convites de desafios encerrados são inválidos."
        description.font = BQFont.body(BQTypeScale.caption)
        description.textColor = .bqText3
        description.numberOfLines = 0
        
        let linkBox = makeLinkBox()
        
        let copyButton = BQButton(title: "Copiar link", icon: "doc.on.doc", variant: .secondary)
        copyButton.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
        
        let shareButton = BQButton(title: "Compartilhar", icon: "square.and.arrow.up")
        shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        
        let buttonsRow = UIStackView(arrangedSubviews: [copyButton, shareButton])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = BQSpacing.sp2
        buttonsRow.distribution = .fillEqually
        
        let previewButton = BQButton(title: "Ver como o convidado recebe", variant: .ghost)
        previewButton.addTarget(self, action: #selector(handlePreview), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [title, description, linkBox, buttonsRow, previewButton])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        toast.configure(text: "Link do convite copiado", tone: .success, systemIcon: "checkmark")
        toast.alpha = 0
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.topAnchor, constant: 12)
        ])
    }
    
    private func makeLinkBox() -> UIView {
        let box = UIView()
        box.backgroundColor = .bqBg0
        box.layer.cornerRadius = BQRadius.small
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.bqStroke1.cgColor
        
        let icon = UIImageView(image: UIImage(systemName: "link"))
        icon.tintColor = .bqText3
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        let label = UILabel()
        label.text = inviteURL
        label.font = BQFont.display(BQTypeScale.caption, weight: .medium)
        label.textColor = .bqText2
        
        let stack = UIStackView(arrangedSubviews: [icon, label, UIView()])
        stack.axis = .horizontal
        stack.spacing = BQSpacing.sp2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12)
        ])
        
        return box
    }
    
    private func showToast() {
        UIView.animate(withDuration: 0.2) {
            self.toast.alpha = 1
        }
        
        UIView.animate(withDuration: 0.2, delay: 1.5) {
            self.toast.alpha = 0
        }
    }
    
    @objc private func handleCopy() {
        UIPasteboard.general.string = inviteURL
        showToast()
    }
    
    @objc private func handleShare() {
        let activity = UIActivityViewController(activityItems: [inviteURL], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = view
        present(activity, animated: true)
    }
    
    @objc private func handlePreview() {
        dismiss(animated: true) { [weak self] in
            self?.onPreviewInvite?()
        }
    }
}
