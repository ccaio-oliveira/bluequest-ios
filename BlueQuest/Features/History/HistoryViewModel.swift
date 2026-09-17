//
//  HistoryViewModel.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 17/09/26.
//

import Foundation

@MainActor
final class HistoryViewModel {
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var monthTitle = ""
    private(set) var cells: [HistoryDayCell] = []
    private(set) var totals: HistoryTotals?
    private(set) var canGoBack = false
    private(set) var canGoForward = false
    
    var onChange: (() -> Void)?
    
    private var monthStart = Date()
    private var days: [String: HistoryDay] = [:]
    
    private static let apiMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    private static let monthName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "pt_BR")
        return calendar
    }
    
    private static let dayTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d 'de' MMMM"
        return formatter
    }()
    
    func load(showingLoader: Bool = true) async {
        if showingLoader { isLoading = true }
        errorMessage = nil
        onChange?()
        
        defer {
            isLoading = false
            onChange?()
        }
        
        do {
            let month = try await HistoryService.shared.month(Self.apiMonth.string(from: monthStart))
            apply(month)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Não foi possível carregar seu histórico."
        }
    }
    
    func goToPreviousMonth() async {
        guard canGoBack, let previous = calendar.date(byAdding: .month, value: -1, to: monthStart) else { return }
              
        monthStart = previous
        await load()
    }
    
    func goToNextMonth() async {
        guard canGoForward, let next = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return }
        
        monthStart = next
        await load()
    }
    
    func title(forDay date: String) -> String {
        guard let parsed = CalendarDayFormatter.localDate(from: date) else { return date }
        return Self.dayTitle.string(from: parsed)
    }
    
    private func apply(_ month: HistoryMonth) {
        totals = month.totals
        days = Dictionary(uniqueKeysWithValues: month.days.map { ($0.date, $0) })
        
        let current = Self.apiMonth.string(from: monthStart)
        canGoBack = current > month.firstMonth
        canGoForward = current < month.lastMonth
        
        monthTitle = Self.monthName.string(from: monthStart).prefix(1).uppercased() + Self.monthName.string(from: monthStart).dropFirst()
        
        cells = makeCells()
    }
    
    private func makeCells() -> [HistoryDayCell] {
        let calendar = self.calendar
        let today = CalendarDayFormatter.dayString(from: Date())
        
        guard let range = calendar.range(of: .day, in: .month, for: monthStart), let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart)) else { return [] }
        
        let leadingBlanks = calendar.component(.weekday, from: firstDay) - 1
        
        var cells = (0..<leadingBlanks).map { _ in
            HistoryDayCell(dayNumber: nil, date: nil, state: .outside, points: 0, hasPhoto: false, isToday: false)
        }
        
        for dayNumber in range {
            guard let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDay) else { continue }
            
            let key = CalendarDayFormatter.dayString(from: date)
            let day = days[key]
            
            cells.append(
                HistoryDayCell(
                    dayNumber: dayNumber,
                    date: day == nil ? nil : key,
                    state: state(for: day, on: key, today: today),
                    points: day?.points ?? 0,
                    hasPhoto: day?.hasPhoto ?? false,
                    isToday: key == today
                )
            )
        }
        
        return cells
    }
    
    private func state(for day: HistoryDay?, on date: String, today: String) -> HistoryDayState {
        guard let day else { return .outside }
        
        if date > today { return .future }
        if day.expired == 0 && day.completed == day.total { return .allDone }
        if day.completed > 0 { return .partial }
        
        return date == today ? .partial : .missed
    }
    
    func day(for date: String) -> HistoryDay? {
        days[date]
    }
}

enum HistoryDayState {
    case outside
    case future
    case allDone
    case partial
    case missed
}

struct HistoryDayCell {
    let dayNumber: Int?
    let date: String?
    let state: HistoryDayState
    let points: Int
    let hasPhoto: Bool
    let isToday: Bool
}
