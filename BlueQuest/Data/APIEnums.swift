//
//  APIEnums.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation

extension OccurrenceState {
    init?(apiValue: String) {
        switch apiValue {
        case "future": self = .future
        case "available": self = .available
        case "completed": self = .completed
        case "expired": self = .expired
        default: return nil
        }
    }
}

extension ChallengeState {
    init?(apiValue: String) {
        switch apiValue {
        case "future": self = .future
        case "in_progress": self = .inProgress
        case "closed": self = .closed
        default: return nil
        }
    }
}
