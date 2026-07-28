//
//  Colors.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

extension UIColor {
    // Base - dark-first
    static let bqBg0 = UIColor(red: 0.023, green: 0.045, blue: 0.076, alpha: 1)        // oklch(0.15 0.02 255)
    static let bqBg1 = UIColor(red: 0.047, green: 0.080, blue: 0.121, alpha: 1)        // oklch(0.19 0.025 255)
    static let bqBg2 = UIColor(red: 0.075, green: 0.116, blue: 0.168, alpha: 1)        // oklch(0.23 0.03 255)
    static let bqStroke1 = UIColor(red: 0.140, green: 0.183, blue: 0.239, alpha: 1)    // oklch(0.30 0.03 255)
    static let bqStroke2 = UIColor(red: 0.211, green: 0.265, blue: 0.333, alpha: 1)    // oklch(0.38 0.035 255)
    
    static let bqText1 = UIColor(red: 0.945, green: 0.956, blue: 0.968, alpha: 1)      // oklch(0.965 0.005 250)
    static let bqText2 = UIColor(red: 0.622, green: 0.663, blue: 0.706, alpha: 1)      // oklch(0.73 0.02 250)
    static let bqText3 = UIColor(red: 0.403, green: 0.451, blue: 0.502, alpha: 1)      // oklch(0.55 0.025 250)
    
    // Brand
    static let bqBlue = UIColor(red: 0.000, green: 0.597, blue: 1.000, alpha: 1)       // oklch(0.67 0.19 250)
    static let bqBlueBright = UIColor(red: 0.391, green: 0.756, blue: 1.000, alpha: 1) // oklch(0.78 0.13 242)
    static let bqBlueDim = UIColor(red: 0.030, green: 0.183, blue: 0.330, alpha: 1)    // oklch(0.30 0.08 252)
    static let bqOnBlue = UIColor(red: 0.010, green: 0.036, blue: 0.083, alpha: 1)     // oklch(0.14 0.03 255)
    
    // Gamificação
    static let bqAmber = UIColor(red: 0.943, green: 0.735, blue: 0.230, alpha: 1)      // oklch(0.82 0.15 85)
    static let bqAmberDim = UIColor(red: 0.254, green: 0.188, blue: 0.026, alpha: 1)   // oklch(0.32 0.06 85)
    static let bqOnAmber = UIColor(red: 0.127, green: 0.076, blue: 0.000, alpha: 1)    // oklch(0.20 0.05 85)
    
    // Estados
    static let bqGreen = UIColor(red: 0.292, green: 0.777, blue: 0.502, alpha: 1)      // oklch(0.74 0.15 155)
    static let bqGreenDim = UIColor(red: 0.036, green: 0.193, blue: 0.107, alpha: 1)   // oklch(0.28 0.06 155)
    static let bqRed = UIColor(red: 0.925, green: 0.358, blue: 0.341, alpha: 1)        // oklch(0.66 0.18 25)
    static let bqRedDim = UIColor(red: 0.272, green: 0.096, blue: 0.088, alpha: 1)     // oklch(0.28 0.07 25)

    // Aliases semânticos
    static let bqStateFuture = bqText3
    static let bqStateAvailable = bqBlueBright
    static let bqStateDone = bqGreen
    static let bqStateExpired = bqRed
}
