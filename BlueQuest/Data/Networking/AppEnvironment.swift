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
        URL(string: "https://a49d-2804-351c-e008-7ca0-188b-3884-2d31-cade.ngrok-free.app/api")!
        #endif
    }
}
