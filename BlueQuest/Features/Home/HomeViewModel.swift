//
//  HomeViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 27/07/26.
//

import Foundation

@MainActor
final class HomeViewModel {
    private(set) var rows: [HomeTaskRow] = []
    var onChange: (() -> Void)?
    
    private let calendar = Calendar(identifier: .gregorian)
    private let now: Date
    
    private let participant: Participant
    private let tasks: [Task]
    private let occurrences: [Occurrence]
    private var completions: [Completion]
    
    init() {
        let today = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        self.now = calendar.date(byAdding: .hour, value: 21, to: today)!
        
        participant = Participant(id: 1, userID: 1, challengeID: 1, joinedAt: today)
        
        tasks = [
            Task(id: 1, challengeID: 1, name: "Beber 2L de água", points: 2, recurrence: .daily, deadlineTime: DateComponents(hour: 21, minute: 30), requiresPhoto: .none),
            
            Task(id: 2, challengeID: 1, name: "Treinar", points: 5, recurrence: .daily, deadlineTime: DateComponents(hour: 21, minute: 30), requiresPhoto: .optional),
            
            Task(id: 3, challengeID: 1, name: "Cardio", points: 3, recurrence: .daily, deadlineTime: DateComponents(hour: 20, minute: 0), requiresPhoto: .none)
        ]
        
        occurrences = [
            Occurrence(id: 1, taskID: 1, date: today),
            Occurrence(id: 2, taskID: 2, date: today),
            Occurrence(id: 3, taskID: 3, date: today)
        ]
        
         completions = [
            Completion(id: 1, participantID: 1, occurrenceID: 1, date: now, pointsAwarded: 2, photoURL: nil)
         ]
        
        rebuildRows()
    }
    
    func completeTask(occurrenceID: Int) {
        guard let occurrence = occurrences.first(where: { $0.id == occurrenceID }),
              let task = tasks.first(where: { $0.id == occurrence.taskID }) else { return }
        
        let isCompleted = completions.contains { $0.occurrenceID == occurrenceID }
        
        do {
            try CompletionRules.validateCompletion(occurrence: occurrence, task: task, isCompleted: isCompleted, requestingUserIsParticipant: true, now: now, calendar: calendar)
        } catch {
            return // Fase futura: expor esse erro pra UI mostrar uma mensagem
        }
        
        let newCompletion = Completion(id: completions.count + 1, participantID: participant.id, occurrenceID: occurrenceID, date: now, pointsAwarded: task.points, photoURL: nil)
        
        completions.append(newCompletion)
        rebuildRows()
        onChange?()
    }
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private func rebuildRows() {
        rows = occurrences.map { occurrence in
            let task = tasks.first { $0.id == occurrence.taskID }!
            let isCompleted = completions.contains { $0.occurrenceID == occurrence.id }
            let state = OccurrenceRules.state(for: occurrence, task: task, isCompleted: isCompleted, now: now, calendar: calendar)
            
            let deadline = OccurrenceRules.deadline(for: occurrence, task: task, calendar: calendar)
            
            return HomeTaskRow(
                occurrenceID: occurrence.id,
                taskName: task.name,
                points: task.points,
                state: state,
                deadlineText: deadline.map { timeFormatter.string(from: $0) } ?? "",
                hasPhoto: task.requiresPhoto != .none
            )
        }
    }
}

struct HomeTaskRow: Equatable {
    let occurrenceID: Int
    let taskName: String
    let points: Int
    let state: OccurrenceState
    let deadlineText: String
    let hasPhoto: Bool
}
