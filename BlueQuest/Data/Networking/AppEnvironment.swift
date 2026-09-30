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
        URL(string: "https://770a-2804-351c-e00e-3ac0-8829-1ba8-b738-1b94.ngrok-free.app/api")!
        #endif
    }
}
