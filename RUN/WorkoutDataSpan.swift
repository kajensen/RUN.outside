//
//  WorkoutDataSet.swift
//  RUN
//
//  Created by Kurt Jensen on 3/31/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

enum WorkoutDataSpan: Int {
    case week, month, year
    
    func date(componentValue: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents(calendarUnits, from: Date())
        switch self {
        case .week:
            if let day = components.day {
                components.day = day + componentValue
            }
        case .month:
            if let day = components.day {
                components.day = day + componentValue
            }
        case .year:
            if let month = components.month {
                components.month = month + componentValue
            }
        }
        return calendar.date(from: components)
    }
    
    var calendarUnits: Set<Calendar.Component> {
        switch self {
        case .week:
            return Set<Calendar.Component>([.day, .month, .year])
        case .month:
            return Set<Calendar.Component>([.day, .month, .year])
        case .year:
            return Set<Calendar.Component>([.month, .year])
        }
    }
    
    var value: Int {
        switch self {
        case .week:
            return 7
        case .month:
            return 28
        case .year:
            return 12
        }
    }
    
    var dates: [Date] {
        var dates: [Date] = []
        for i in -value...0 {
            if let date = date(componentValue: i) {
                dates.append(date)
            }
        }
        return dates
    }
    
    var title: String {
        switch self {
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        }
    }
    
}
