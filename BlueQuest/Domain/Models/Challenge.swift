//
//  Challenge.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct Challenge: Identifiable, Codable {
    let id: Int
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var creatorUserID: Int
}

enum ChallengeState: Equatable {
    case future
    case inProgress
    case closed
}
