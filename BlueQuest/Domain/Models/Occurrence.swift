//
//  Occurrence.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

struct Occurrence: Equatable, Hashable {
    var taskID: Int
    var date: Date
}

enum OccurrenceState: Equatable {
    case future
    case available
    case completed
    case expired
}

extension Occurrence {
    func isCompleted(in completions: [Completion], calendar: Calendar) -> Bool {
        completions.contains { completion in
            completion.taskID == taskID && calendar.isDate(completion.occurrenceDate, inSameDayAs: date)
        }
    }
}
