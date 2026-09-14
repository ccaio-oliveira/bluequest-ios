//
//  CalendarDayFormatter.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation

enum CalendarDayFormatter {
    private static let parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    private static let timeParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private static let timeDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private static let localDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let localTimeParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static func periodText(from start: String, to end: String) -> String {
        guard let startDate = parser.date(from: start), let endDate = parser.date(from: end) else { return "" }
        
        let endText = dayMonth.string(from: endDate).replacingOccurrences(of: ".", with: "")
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        if calendar.isDate(startDate, equalTo: endDate, toGranularity: .month) {
            return "\(calendar.component(.day, from: startDate))-\(endText)"
        }
        
        let startText = dayMonth.string(from: startDate).replacingOccurrences(of: ".", with: "")
        
        return "\(startText) - \(endText)"
    }
    
    static func timeText(from hhmm: String) -> String {
        guard let date = timeParser.date(from: hhmm) else { return hhmm }
        return timeDisplay.string(from: date)
    }
    
    static func dayMonthText(from date: String) -> String {
        guard let parsed = parser.date(from: date) else { return date }
        
        return dayMonth.string(from: parsed).replacingOccurrences(of: ".", with: "")
    }
    
    static func localDate(from day: String) -> Date? {
        localDay.date(from: day)
    }
    
    static func dayString(from date: Date) -> String {
        localDay.string(from: date)
    }
    
    static func localTime(from hhmm: String) -> Date? {
        localTimeParser.date(from: hhmm)
    }
    
    static func timeString(from date: Date) -> String {
        localTimeParser.string(from: date)
    }
}
