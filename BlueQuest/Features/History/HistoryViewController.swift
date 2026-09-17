//
//  HistoryViewController.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class HistoryViewController: UIViewController {
    var onBack: (() -> Void)?
    
    private let viewModel: HistoryViewModel
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let statsRow = UIStackView()
    private let monthLabel = UILabel()
    private let previousButton = IconButtonView(icon: "chevron.left", variant: .ghost)
    private let nextButton = IconButtonView(icon: "chevron.right", variant: .ghost)
    private let calendarView = CalendarMonthView()
    private let calendarCard = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: HistoryViewModel) {
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
        
        viewModel.onChange = { [weak self] in
            self?.render()
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
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = BQSpacing.sp4
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        statsRow.axis = .horizontal
        statsRow.spacing = BQSpacing.sp2
        statsRow.distribution = .fillEqually
        
        let footnote = UILabel()
        footnote.text = "Dias sem registro não podem ser preenchidos depois - sem backfill."
        footnote.font = BQFont.body(12)
        footnote.textColor = .bqText3
        footnote.textAlignment = .center
        footnote.numberOfLines = 0
        
        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(statsRow)
        contentStack.addArrangedSubview(makeCalendarCard())
        contentStack.addArrangedSubview(footnote)
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: content.topAnchor, constant: BQSpacing.sp2),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -BQSpacing.sp2),
            contentStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: BQSpacing.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -BQSpacing.screenPadding),
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -2 * BQSpacing.screenPadding)
        ])
    }
    
    private func makeHeader() -> UIView {
        let backButton = IconButtonView(icon: "arrow.left")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Seu histórico"
        titleLabel.font = BQFont.display(BQTypeScale.title2, weight: .bold)
        titleLabel.textColor = .bqText1
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Conclusões por dia, em todos os desafios"
        subtitleLabel.font = BQFont.body(BQTypeScale.caption)
        subtitleLabel.textColor = .bqText3
        subtitleLabel.numberOfLines = 2
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        
        let headerRow = UIStackView(arrangedSubviews: [backButton, titleStack])
        headerRow.axis = .horizontal
        headerRow.spacing = BQSpacing.sp3
        headerRow.alignment = .center
        
        return headerRow
    }
    
    private func makeCalendarCard() -> UIView {
        calendarCard.backgroundColor = .bqBg1
        calendarCard.layer.cornerRadius = BQRadius.medium
        calendarCard.layer.borderWidth = 1
        calendarCard.layer.borderColor = UIColor.bqStroke1.cgColor
        
        monthLabel.font = BQFont.display(BQTypeScale.headline, weight: .bold)
        monthLabel.textColor = .bqText1
        monthLabel.textAlignment = .center
        
        previousButton.addTarget(self, action: #selector(handlePrevious), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        
        loadingIndicator.color = .bqText3
        loadingIndicator.hidesWhenStopped = true
        
        let monthRow = UIStackView(arrangedSubviews: [previousButton, monthLabel, loadingIndicator, nextButton])
        monthRow.axis = .horizontal
        monthRow.spacing = BQSpacing.sp2
        monthRow.alignment = .center
        
        calendarView.onSelectDay = { [weak self] date in
            self?.presentDay(date)
        }
        
        let stack = UIStackView(arrangedSubviews: [monthRow, calendarView, makeLegend()])
        stack.axis = .vertical
        stack.spacing = BQSpacing.sp3
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        calendarCard.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: calendarCard.topAnchor, constant: BQSpacing.cardPadding),
            stack.bottomAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: -BQSpacing.cardPadding),
            stack.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: BQSpacing.cardPadding),
            stack.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -BQSpacing.cardPadding)
        ])
        
        return calendarCard
    }
    
    private func makeLegend() -> UIView {
        let items: [(UIColor, UIColor, String)] = [
            (.bqGreenDim, .bqGreen, "tudo concluído"),
            (.bqAmberDim, .bqAmber, "parcial"),
            (.clear, .bqRed, "sem registro"),
            (.bqStroke1, .bqStroke1, "com foto")
        ]
        
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = BQSpacing.sp3
        row.distribution = .fillProportionally
        
        items.forEach { fill, border, title in
            let dot = UIView()
            dot.backgroundColor = fill
            dot.layer.cornerRadius = 3
            dot.layer.borderWidth = 1
            dot.layer.borderColor = border.cgColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = title
            label.font = BQFont.body(BQTypeScale.micro)
            label.textColor = .bqText3
            
            let item = UIStackView(arrangedSubviews: [dot, label])
            item.axis = .horizontal
            item.spacing = 4
            item.alignment = .center
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 10),
                dot.heightAnchor.constraint(equalToConstant: 10)
            ])
            
            row.addArrangedSubview(item)
        }
        
        return row
    }
    
    private func render() {
        monthLabel.text = viewModel.monthTitle
        
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        previousButton.isEnabled = viewModel.canGoBack
        previousButton.alpha = viewModel.canGoBack ? 1 : 0.3
        nextButton.isEnabled = viewModel.canGoForward
        nextButton.alpha = viewModel.canGoForward ? 1 : 0.3
        
        calendarView.configure(with: viewModel.cells)
        
        statsRow.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        if let totals = viewModel.totals {
            [
                StatTileView(icon: "checkmark.circle.fill", value: "\(totals.completions)", label: "conclusões"),
                StatTileView(icon: "bolt.fill", value: "\(totals.points)", label: "pontos totais", tone: .points),
                StatTileView(icon: "flame.fill", value: "\(totals.streakDays)", label: "dias seguidos", tone: .primary)
            ].forEach { statsRow.addArrangedSubview($0) }
        }
        
        if let message = viewModel.errorMessage {
            showError(message)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func presentDay(_ date: String) {
        guard let day = viewModel.day(for: date) else { return }
        
        let sheet = HistoryDaySheetViewController(day: day, title: viewModel.title(forDay: date))
        present(sheet, animated: true)
    }
    
    @objc private func handleBack() {
        onBack?()
    }
    
    @objc private func handlePrevious() {
        Task { await viewModel.goToPreviousMonth() }
    }
    
    @objc private func handleNext() {
        Task { await viewModel.goToNextMonth() }
    }
}
