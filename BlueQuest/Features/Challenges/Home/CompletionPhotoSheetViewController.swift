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
    var onFinish: ((Data) -> Void)?
    
    private let taskName: String
    private let points: Int
    
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
        
        let titleLabel = UILabel()
        titleLabel.text = "Concluir: \(taskName)"
        titleLabel.font = BQFont.display(16, weight: .semibold)
        titleLabel.textColor = .bqText1
        titleLabel.numberOfLines = 0
        
        let hint = UILabel()
        hint.text = "Esta tarefa exige foto · +\(points) pts"
        hint.font = BQFont.body(BQTypeScale.caption)
        hint.textColor = .bqText3
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, hint])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp3
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = BQButton(title: "Tirar foto", icon: "camera.fill", size: .lg)
            cameraButton.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
            stack.addArrangedSubview(cameraButton)
        }
        
        let galleryButton = BQButton(title: "Escolher da galeria", icon: "photo.on.rectangle", variant: .secondary, size: .lg)
        galleryButton.addTarget(self, action: #selector(handleGallery), for: .touchUpInside)
        stack.addArrangedSubview(galleryButton)
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
        ])
    }
    
    private func finish(with image: UIImage) {
        guard let jpeg = PhotoService.jpegData(from: image) else { return }
        
        let handler = onFinish
        onFinish = nil
        
        presentingViewController?.dismiss(animated: true) { handler?(jpeg) }
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
}

extension CompletionPhotoSheetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            
            Task { @MainActor [weak self] in
                self?.finish(with: image)
            }
        }
    }
}

extension CompletionPhotoSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        finish(with: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
