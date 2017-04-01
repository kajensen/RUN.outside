//
//  WorkoutData.swift
//  RUN
//
//  Created by Kurt Jensen on 3/31/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

enum WorkoutData {
    
    case speed, elevation, heartbeat, distance
    
    var title: String {
        switch self {
        case .speed:
            return "SPEED"
        case .elevation:
            return "ELEVATION"
        case .heartbeat:
            return "HEARTBEAT"
        case .distance:
            return "DISTANCE"
        }
    }

}
