//
//  User.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    var name: String
    var email: String
    var avatarURL: URL?
}
