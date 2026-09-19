//
//  PhotoViewerViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 18/09/26.
//

import Foundation
import UIKit

final class PhotoViewerViewController: UIViewController {
    private let url: URL
    private let caption: String
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let captionLabel = UILabel()
    
    init(url: URL, caption: String) {
        self.url = url
        self.caption = caption
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        
        spinner.color = .bqText3
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        let closeButton = IconButtonView(icon: "xmark")
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        captionLabel.text = caption
        captionLabel.font = BQFont.body(BQTypeScale.caption, weight: .medium)
        captionLabel.textColor = .bqText2
        captionLabel.numberOfLines = 0
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captionLabel)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: content.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: frame.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: frame.heightAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: BQSpacing.sp2),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            
            captionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -BQSpacing.sp4),
            captionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BQSpacing.screenPadding),
            captionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BQSpacing.screenPadding)
        ])
        
        Task {
            imageView.image = await ImageLoader.shared.image(for: url)
            spinner.stopAnimating()
        }
    }
    
    @objc private func handleDoubleTap() {
        let target: CGFloat = scrollView.zoomScale > 1 ? 1 : 2.5
        scrollView.setZoomScale(target, animated: true)
    }
    
    @objc private func handleClose() {
        dismiss(animated: true)
    }
}

extension PhotoViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        captionLabel.alpha = scrollView.zoomScale > 1 ? 0 : 1
    }
}
