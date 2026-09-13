//
//  OverlineLabel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 11/09/26.
//

import Foundation
import UIKit

final class OverlineLabel: UILabel {
    init(_ text: String, color: UIColor = .bqText3) {
        super.init(frame: .zero)
        font = BQFont.body(BQTypeScale.micro, weight: .semibold)
        textColor = color
        setText(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        attributedText = NSAttributedString(
            string: text.uppercased(),
            attributes: [.kern: BQTypeScale.micro * 0.08]
        )
    }
}
