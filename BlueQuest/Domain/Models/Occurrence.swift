//
//  Occurrence.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct Occurrence: Identifiable, Codable {
    let id: Int
    var taskID: Int
    var date: Date
}

enum OccurrenceState: Equatable {
    case future
    case available
    case completed
    case expired
}

func occurrenceState(
    for occurrence: Occurrence,
    task: Task,
    isCompleted: Bool,
    now: Date
) -> OccurrenceState {
    // ainda vazio - Fase 2
    return .available
}
