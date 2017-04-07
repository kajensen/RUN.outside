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
    
    func value(valueSums: Double, count: Int) -> Double {
        let value: Double
        switch self {
        case .speed, .heartrate:
            value = valueSums/Double(count)
        case .distance, .elevation:
            value = valueSums
        }
        return value.isNaN ? 0 : value
    }

}
