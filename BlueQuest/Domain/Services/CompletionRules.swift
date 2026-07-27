//
//  CompletionRules.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation

enum CompletionError: Error, Equatable {
    case userNotParticipant
    case occurrenceNotAvailable(OccurrenceState)
}

enum CompletionRules {
    static func validateCompletion(
        occurrence: Occurrence,
        task: Task,
        isCompleted: Bool,
        requestingUserIsParticipant: Bool,
        now: Date,
        calendar: Calendar = .current
    ) throws {
        guard requestingUserIsParticipant else {
            throw CompletionError.userNotParticipant
        }
        
        let state = OccurrenceRules.state(
            for: occurrence,
            task: task,
            isCompleted: isCompleted,
            now: now,
            calendar: calendar
        )
        
        guard state == .available else {
            throw CompletionError.occurrenceNotAvailable(state)
        }
    }
}
