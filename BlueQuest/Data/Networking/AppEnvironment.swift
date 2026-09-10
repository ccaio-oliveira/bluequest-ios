//
//  AppEnvironment.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation

enum AppEnvironment {
    static var apiBaseURL: URL {
        #if targetEnvironment(simulator)
        URL(string: "http://127.0.0.1:8000/api")!
        #else
        URL(string: "http://MacBook-Pro-de-Caio.local:8000/api")!
        #endif
    }
}
