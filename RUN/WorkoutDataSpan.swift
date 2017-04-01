//
//  WorkoutDataSet.swift
//  RUN
//
//  Created by Kurt Jensen on 3/31/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

struct WorkoutDataSet {

    var points: [Date: Double]

    enum Span: Int {
        case week, month, year
        
        func date(componentValue: Int) -> Date? {
            let calendar = Calendar.current
            var components = calendar.dateComponents(calendarUnits, from: Date())
            switch self {
            case .week:
                components.day = components.day! + componentValue
            case .month:
                components.day = components.day! + componentValue
            case .year:
                components.month = components.month! + componentValue
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
        
        var dates: [(from: Date, to: Date)] {
            var dates: [(from: Date, to: Date)] = []
            for i in -value..<0 {
                if let fromDate = date(componentValue: i), let toDate = date(componentValue: i+1) {
                    dates.append((fromDate, toDate))
                }
            }
            return dates
        }
        
    }
}
