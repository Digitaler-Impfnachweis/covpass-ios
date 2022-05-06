//
//  Date+Extension.swift
//  
//
//  Created by Thomas Kuleßa on 03.05.22.
//

import Foundation

public extension Date {
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
        let months = diffComponents.day ?? 0
        return months
    }

    func hoursSince(_ date: Date) -> Int {
        let components: Set<Calendar.Component> = [.hour]
        let diffComponents = Calendar.current.dateComponents(
            components,
            from: date,
            to: self
        )
        let months = diffComponents.hour ?? 0
        return months
    }
}
