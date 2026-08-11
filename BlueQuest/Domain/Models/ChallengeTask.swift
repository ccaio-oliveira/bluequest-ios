//
//  Task.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct ChallengeTask: Identifiable, Codable {
    let id: Int
    var challengeID: Int
    var name: String
    var description: String?
    var points: Int
    var recurrence: Recurrence
    var deadlineTime: DateComponents
    var requiresPhoto: PhotoRequirement
}

enum PhotoRequirement: String, Codable {
    case none
    case optional
    case required
}
