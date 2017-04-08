//
//  WorkoutData.swift
//  RUN
//
//  Created by Kurt Jensen on 3/31/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

enum WorkoutData: Int {
    
    case speed, elevation, heartrate, distance
    
    var title: String {
        switch self {
        case .speed:
            return "AVG SPEED"
        case .elevation:
            return "ELEVATION"
        case .heartrate:
            return "AVG HEARTRATE"
        case .distance:
            return "DISTANCE"
        }
    }
    
    func string(value: Double) -> String {
        switch self {
        case .speed:
            return Utils.distanceRateString(unitsPerHour: Utils.unitsPerHour(metersPerSecond: value))
        case .distance:
            return Utils.longDistanceString(meters: value)
        case .heartrate:
            return "\(Int(value)) bmp"
        case .elevation:
            return Utils.shortDistanceString(meters: value)
        }
    }
    
    func value(values: [Double]) -> Double {
        guard values.count > 0 else {
            return 0
        }
        var valueSum: Double = 0
        for value in values {
            valueSum += value
        }
        let value: Double
        switch self {
        case .speed, .heartrate, .elevation:
            value = valueSum/Double(values.count)
        case .distance:
            value = valueSum
        }
        return value.isNaN ? 0 : value
    }
    
    func value(_ event: WorkoutEvent, previousEvent: WorkoutEvent?) -> Double {
        switch self {
        case .speed:
            return event.speed
        case .distance:
            return event.distanceTraveled
        case .heartrate:
            return event.heartRate
        case .elevation:
            return event.altitude
        }
    }

}
