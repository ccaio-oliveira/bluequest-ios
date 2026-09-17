//
//  CalendarMonthView.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation
import UIKit

final class CalendarMonthView: UIView {
    var onSelectDay: ((String) -> Void)?
    
    private let gridStack = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with cells: [HistoryDayCell]) {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for week in stride(from: 0, to: cells.count, by: 7) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 4
            row.distribution = .fillEqually
            
            for index in week..<min(week + 7, cells.count) {
                let cell = cells[index]
                let view = HistoryDayCellView()
                view.configure(with: cell)
                
                view.onTap = { [weak self] in
                    guard let date = cell.date else { return }
                    self?.onSelectDay?(date)
                }
                
                row.addArrangedSubview(view)
            }
            
            while row.arrangedSubviews.count < 7 {
                row.addArrangedSubview(UIView())
            }
            
            gridStack.addArrangedSubview(row)
        }
    }
    
    private func setupViews() {
        let weekdaysRow = UIStackView()
        weekdaysRow.axis = .horizontal
        weekdaysRow.spacing = 4
        weekdaysRow.distribution = .fillEqually
        
        ["D", "S", "T", "Q", "Q", "S", "S"].forEach { title in
            let label = UILabel()
            label.text = title
            label.font = BQFont.body(BQTypeScale.micro, weight: .semibold)
            label.textColor = .bqText3
            label.textAlignment = .center
            weekdaysRow.addArrangedSubview(label)
        }
        
        gridStack.axis = .vertical
        gridStack.spacing = 4
        
        let stack = UIStackView(arrangedSubviews: [weekdaysRow, gridStack])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
