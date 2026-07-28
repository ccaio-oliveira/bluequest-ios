//
//  Typography.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

enum BQFont {
    static func display(_ size: CGFloat, weight: UIFont.Weight = .bold) -> UIFont {
        let name: String
        
        switch weight {
        case .bold: name = "SpaceGrotesk-Bold"
        case .semibold: name = "SpaceGrotesk-SemiBold"
        case .medium: name = "SpaceGrotesk-Medium"
        default: name = "SpaceGrotesk-Regular"
        }
        
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
    
    static func body(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}

enum BQTypeScale {
    static let hero: CGFloat = 40
    static let title1: CGFloat = 28
    static let title2: CGFloat = 22
    static let headline: CGFloat = 17
    static let body: CGFloat = 15
    static let caption: CGFloat = 13
    static let micro: CGFloat = 11
}
