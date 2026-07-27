//
//  Recurrence.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 26/07/26.
//

import Foundation

enum Recurrence: Codable, Equatable {
    case once(Date)
    case daily
    case weekdays(Set<Weekday>)
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}
