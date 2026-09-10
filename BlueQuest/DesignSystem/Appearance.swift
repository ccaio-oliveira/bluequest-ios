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
    
    static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.bqBg0.withAlphaComponent(0.85)
        appearance.shadowColor = .bqStroke1
        
        for item in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            
            item.normal.iconColor = .bqText3
            item.normal.titleTextAttributes = [
                .foregroundColor: UIColor.bqText3,
                .font: BQFont.body(11, weight: .semibold)
            ]
            
            item.selected.iconColor = .bqBlueBright
            item.selected.titleTextAttributes = [
                .foregroundColor: UIColor.bqBlueBright,
                .font: BQFont.body(11, weight: .semibold)
            ]
        }
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
