//
//  Appearance.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

enum BQAppearance {
    static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .bqBg0
        appearance.titleTextAttributes = [.foregroundColor: UIColor.bqText1]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.bqText1]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .bqBlueBright
    }
}
