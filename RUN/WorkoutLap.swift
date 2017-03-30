//
//  WorkoutLap.swift
//  RUN
//
//  Created by Kurt Jensen on 3/30/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift
import CoreLocation

class WorkoutLap: Object {
    
    dynamic var startDate: Date?
    dynamic var endDate: Date?
    dynamic var netAltitude: Double = 0
    dynamic var totalPositiveAltitude: Double = 0
    dynamic var totalDistance: Double = 0
    dynamic var totalTimeActive: Double = 0
    var events = List<WorkoutEvent>()
    
    private var lastActiveDate: Date?
    override static func ignoredProperties() -> [String] {
        return ["lastActiveDate"]
    }
    
    var currentTimeActive: TimeInterval {
        var currentTimeElapsed = totalTimeActive
        if let lastActiveDate = lastActiveDate, lastActiveDate.timeIntervalSinceNow < 0 {
            currentTimeElapsed += -lastActiveDate.timeIntervalSinceNow
        }
        return currentTimeElapsed
    }
    
    convenience init(startDate: Date, location: CLLocation) {
        self.init()
        self.startDate = startDate
        addEvent(location, type: .resume)
    }
    
    func end() {
        self.endDate = Date()
    }
    
    func addEvent(_ location: CLLocation, type: WorkoutEvent.WorkoutEventType) {
        let newEvent = WorkoutEvent(location: location, type: type)
        if let lastEvent = events.last, lastEvent.workoutEventType != .pause {
            let altitudeDifference = newEvent.altitudeDifference(to: lastEvent)
            netAltitude += altitudeDifference.net
            totalPositiveAltitude += altitudeDifference.positive
            totalDistance += newEvent.distanceDifference(to: lastEvent)
            totalTimeActive += newEvent.timeDifference(to: lastEvent)
        }
        events.append(newEvent)
        switch type {
        case .locationUpdate:
            totalTimeActive = currentTimeActive
            lastActiveDate = Date()
        case .pause:
            totalTimeActive = currentTimeActive
            lastActiveDate = nil
        case .resume:
            lastActiveDate = Date()
        }
    }
    
}
