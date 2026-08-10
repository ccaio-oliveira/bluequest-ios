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
        URL(string: "http://192.168.1.6:8000/api")!
        #endif
    }
}
