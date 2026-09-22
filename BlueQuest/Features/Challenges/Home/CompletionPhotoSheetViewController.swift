//
//  CompletionPhotoSheetViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import PhotosUI
import UIKit

final class CompletionPhotoSheetViewController: UIViewController {
    var onFinish: ((String) -> Void)?
    
    private enum Step {
        case choose, uploading, failed, done
    }
    
    private let taskName: String
    private let points: Int
    
    private var step: Step = .choose {
        didSet { render() }
    }
    
    private var pickedImage: UIImage?
    
    private let titleLabel = UILabel()
    private let contentStack = UIStackView()
    
    init(taskName: String, points: Int) {
        self.taskName = taskName
        self.points = points
        super.init(nibName: nil, bundle: nil)
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
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
        
        titleLabel.text = "Concluir: \(taskName)"
        titleLabel.font = BQFont.display(16, weight: .semibold)
        titleLabel.textColor = .bqText1
        titleLabel.numberOfLines = 0
        
        contentStack.axis = .vertical
        contentStack.spacing = BQSpacing.sp2
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentStack])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp3
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
        ])
        
        render()
    }
    
    private func render() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        isModalInPresentation = step == .uploading
        
        switch step {
        case .choose:
            makeChooseViews().forEach { contentStack.addArrangedSubview($0) }
        case .uploading:
            makeUploadingViews().forEach { contentStack.addArrangedSubview($0) }
        case .failed:
            makeFailedViews().forEach { contentStack.addArrangedSubview($0) }
        case .done:
            makeDoneViews().forEach { contentStack.addArrangedSubview($0) }
        }
    }
    
    private func makeChooseViews() -> [UIView] {
        let hint = UILabel()
        hint.text = "Esta tarefa exige foto · +\(points) pts"
        hint.font = BQFont.body(BQTypeScale.caption)
        hint.textColor = .bqText3
        
        let galleryButton = BQButton(title: "Escolher da galeria", icon: "photo.on.rectangle", variant: .secondary, size: .lg)
        galleryButton.addTarget(self, action: #selector(handleGallery), for: .touchUpInside)
        
        var views: [UIView] = [hint]
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = BQButton(title: "Tirar foto", icon: "camera.fill", size: .lg)
            cameraButton.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
            views.append(cameraButton)
        }
        
        views.append(galleryButton)
        
        return views
    }
    
    private func makeUploadingViews() -> [UIView] {
        let preview = UIImageView(image: pickedImage)
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        preview.layer.cornerRadius = BQRadius.small
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .bqText3
        spinner.startAnimating()
        
        let label = UILabel()
        label.text = "Enviando foto..."
        label.font = BQFont.body(BQTypeScale.body, weight: .semibold)
        label.textColor = .bqText2
        
        let row = UIStackView(arrangedSubviews: [spinner, label])
        row.axis = .horizontal
        row.spacing = BQSpacing.sp2
        row.alignment = .center
        
        let column = UIStackView(arrangedSubviews: [preview, row])
        column.axis = .vertical
        column.spacing = BQSpacing.sp3
        column.alignment = .center
        
        NSLayoutConstraint.activate([
            preview.widthAnchor.constraint(equalToConstant: 120),
            preview.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return [column]
    }
    
    private func makeFailedViews() -> [UIView] {
        let banner = BannerView()
        banner.configure(text: "Falha no envio da foto. A conclusão não foi registrada.", tone: .error)
        
        let retryButton = BQButton(title: "Tentar de novo", icon: "arrow.clockwise", size: .lg)
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        let otherButton = BQButton(title: "Escolher outra foto", variant: .ghost, size: .lg)
            otherButton.addTarget(self, action: #selector(handleChooseAgain), for: .touchUpInside)
        
        return [banner, retryButton, otherButton]
    }
    
    private func makeDoneViews() -> [UIView] {
        let iconView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iconView.tintColor = .bqGreen
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Foto enviada"
        label.font = BQFont.display(BQTypeScale.headline, weight: .bold)
        label.textColor = .bqText1
        
        let column = UIStackView(arrangedSubviews: [iconView, label])
        column.axis = .vertical
        column.spacing = BQSpacing.sp2
        column.alignment = .center
        
        return [column]
    }
    
    private func upload(_ image: UIImage) {
        pickedImage = image
        step = .uploading
        
        Task {
            do {
                let url = try await PhotoService.shared.uploadCompletionPhoto(image)
                
                step = .done
                try? await Task.sleep(for: .milliseconds(700))
                finish(with: url)
            } catch {
                step = .failed
            }
        }
    }
    
    private func finish(with url: String) {
        let handler = onFinish
        onFinish = nil
        
        dismiss(animated: true) { handler?(url) }
    }
    
    @objc private func handleCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @objc private func handleGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @objc private func handleRetry() {
        guard let pickedImage else {
            step = .choose
            return
        }
        
        upload(pickedImage)
    }
    
    @objc private func handleChooseAgain() {
        step = .choose
    }
}

extension CompletionPhotoSheetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            
            Task { @MainActor in
                self?.upload(image)
            }
        }
    }
}

extension CompletionPhotoSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerConTotroller(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        upload(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
