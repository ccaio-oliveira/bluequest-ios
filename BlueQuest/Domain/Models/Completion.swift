//
//  Completion.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct Completion: Identifiable, Codable {
    let id: Int
    var participantID: Int
    var occurrenceID: Int
    var date: Date
    var pointsAwarded: Int
    var photoURL: URL?
}
