//
//  Date+Extension.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Date {
    
    var passed24Hours: Bool {
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: self) else {
            return false
        }
        return Date() > date
    }
    
    var isOlderThan29Days: Bool {
        guard let date = Calendar.current.date(byAdding: .day, value: 29, to: self) else {
            return false
        }
        return Date() > date
    }
    
    func monthsSince(_ date: Date) -> Int {
        let components: Set<Calendar.Component> = [.month]
        let diffComponents = Calendar.current.dateComponents(
            components,
            from: date,
            to: self
        )
        let months = diffComponents.month ?? 0
        return months
    }

    func daysSince(_ date: Date) -> Int {
        let components: Set<Calendar.Component> = [.day]
        let diffComponents = Calendar.current.dateComponents(
            components,
            from: date,
            to: self
        )
        let days = diffComponents.day ?? 0
        return days
    }

    func hoursSince(_ date: Date) -> Int {
        let components: Set<Calendar.Component> = [.hour]
        let diffComponents = Calendar.current.dateComponents(
            components,
            from: date,
            to: self
        )
        let hours = diffComponents.hour ?? 0
        return hours
    }

    func yearsSince(_ date: Date) -> Int {
        let components: Set<Calendar.Component> = [.year]
        let diffComponents = Calendar.current.dateComponents(
            components,
            from: date,
            to: self
        )
        let years = diffComponents.year ?? 0
        return years
    }

    var endOfYear: Self? {
        let dateInterval = Calendar.current.dateInterval(of: .year, for: self)
        return dateInterval?.end
    }

    var endOfMonth: Self? {
        let dateInterval = Calendar.current.dateInterval(of: .month, for: self)
        return dateInterval?.end
    }
    
    func add(days: Int) -> Self? {
        var dateComponent = DateComponents()
        dateComponent.day = days
        return Calendar.current.date(byAdding: dateComponent, to: self)
    }
}
