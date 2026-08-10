//
//  OccurrenceRulesTests.swift
//  BlueQuestTests
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation
import XCTest
@testable import BlueQuest

final class OccurrenceRulesTests: XCTestCase {
    
    private let calendar = Calendar(identifier: .gregorian)
    
    private func makeTask(deadlineHour: Int = 22) -> Task {
        Task(
            id: 1,
            challengeID: 1,
            name: "Cardio",
            description: nil,
            points: 3,
            recurrence: .daily,
            deadlineTime: DateComponents(hour: deadlineHour, minute: 0),
            requiresPhoto: .none
        )
    }
    
    func test_whenCompleted_returnsCompleted() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 23, minute: 0))!
        
        let state = OccurrenceRules.state(for: occurrence, task: makeTask(), isCompleted: true, now: now, calendar: calendar)
        
        XCTAssertEqual(state, .completed)
    }
    
    func test_whenAvailable_returnsAvailable() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 12, minute: 0))!
        
        let state = OccurrenceRules.state(for: occurrence, task: makeTask(), isCompleted: false, now: now, calendar: calendar)
        
        XCTAssertEqual(state, .available)
    }
    
    func test_whenExpired_returnsExpired() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 5, hour: 23, minute: 0))!
        
        let state = OccurrenceRules.state(for: occurrence, task: makeTask(), isCompleted: false, now: now, calendar: calendar)
        
        XCTAssertEqual(state, .expired)
    }
    
    func test_whenFuture_returnsFuture() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 3, hour: 23, minute: 0))!
        
        let state = OccurrenceRules.state(for: occurrence, task: makeTask(), isCompleted: false, now: now, calendar: calendar)
        
        XCTAssertEqual(state, .future)
    }
    
    func test_atExactDeadline_returnsAvailable() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 22, minute: 0, second: 0))!

        let state = OccurrenceRules.state(for: occurrence, task: makeTask(), isCompleted: false, now: now, calendar: calendar)

        XCTAssertEqual(state, .available)
    }

    func test_oneSecondAfterDeadline_returnsExpired() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 22, minute: 0, second: 1))!

        let state = OccurrenceRules.state(for: occurrence, task: makeTask(), isCompleted: false, now: now, calendar: calendar)

        XCTAssertEqual(state, .expired)
    }
    
    func test_whenNotParticipant_throwsUserNotParticipant() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 12, minute: 0))!
        
        XCTAssertThrowsError(
            try CompletionRules.validateCompletion(
                occurrence: occurrence,
                task: makeTask(),
                isCompleted: false,
                requestingUserIsParticipant: false,
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? CompletionError, .userNotParticipant)
        }
    }
    
    func test_whenParticipant_throwsNothing() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 12, minute: 0))!
        
        XCTAssertNoThrow(
            try CompletionRules.validateCompletion(
                occurrence: occurrence,
                task: makeTask(),
                isCompleted: false,
                requestingUserIsParticipant: true,
                now: now,
                calendar: calendar
            )
        )
    }
    
    func test_whenParticipant_throwsCompleted() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 12, minute: 0))!
        
        XCTAssertThrowsError(
            try CompletionRules.validateCompletion(
                occurrence: occurrence,
                task: makeTask(),
                isCompleted: true,
                requestingUserIsParticipant: true,
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? CompletionError, .occurrenceNotAvailable(.completed))
        }
    }
    
    func test_whenParticipant_throwsExpired() {
        let occurrenceDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4))!
        let occurrence = Occurrence(taskID: 1, date: occurrenceDate)
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 22, minute: 1))!
        
        XCTAssertThrowsError(
            try CompletionRules.validateCompletion(
                occurrence: occurrence,
                task: makeTask(),
                isCompleted: false,
                requestingUserIsParticipant: true,
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? CompletionError, .occurrenceNotAvailable(.expired))
        }
    }
}
