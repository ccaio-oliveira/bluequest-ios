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
}
