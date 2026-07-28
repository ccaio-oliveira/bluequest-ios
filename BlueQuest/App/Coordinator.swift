//
//  Coordinator.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation
import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
