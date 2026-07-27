//
//  Participant.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct Participant: Identifiable, Codable, Equatable {
    let id: Int
    var userID: Int
    var challengeID: Int
    var joinedAt: Date
}
