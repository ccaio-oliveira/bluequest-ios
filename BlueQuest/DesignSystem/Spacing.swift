//
//  Spacing.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import CoreGraphics

enum BQSpacing {
    static let sp1: CGFloat = 4
    static let sp2: CGFloat = 8
    static let sp3: CGFloat = 12
    static let sp4: CGFloat = 16
    static let sp5: CGFloat = 20
    static let sp6: CGFloat = 24
    static let sp8: CGFloat = 32
    static let sp10: CGFloat = 40
    static let sp12: CGFloat = 48
    
    static let screenPadding: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let hitTarget: CGFloat = 44
}


enum BQRadius {
    static let small: CGFloat = 10     // chips, inputs
    static let medium: CGFloat = 14    // cards
    static let large: CGFloat = 20     // sheets, hero
    static let full: CGFloat = 999
}
