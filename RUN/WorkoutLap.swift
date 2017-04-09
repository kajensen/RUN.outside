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
    
    var infoString: String {
        let time = TimeInterval(totalTimeActive).formatted()
        let distance = Utils.longDistanceString(meters: totalDistance)
        let elevation = "\(Utils.shortDistanceString(meters: netAltitude)) (+\(Utils.shortDistanceString(meters: totalPositiveAltitude)))"
        return "\(time) • \(distance) • \(elevation)"
    }
    
    var currentTimeActive: TimeInterval {
        var currentTimeElapsed = totalTimeActive
        if let lastActiveDate = lastActiveDate, lastActiveDate.timeIntervalSinceNow < 0 {
            currentTimeElapsed += -lastActiveDate.timeIntervalSinceNow
        }
        return currentTimeElapsed
    }
    
    convenience init(startDate: Date, location: CLLocation, type: WorkoutEvent.WorkoutEventType) {
        self.init()
        self.startDate = startDate
        addEvent(location, type: type)
    }
    
    func end() {
        self.endDate = Date()
    }
    
    func addEvent(_ location: CLLocation, type: WorkoutEvent.WorkoutEventType) {
        let lastEvent = events.last
        let newEvent = WorkoutEvent(location: location, lastEvent: lastEvent, heartRate: 0, type: type)
        if let lastEvent = lastEvent, lastEvent.workoutEventType != .pause {
            let altitudeDifference = newEvent.altitudeDifference(to: lastEvent)
            netAltitude += altitudeDifference.net
            totalPositiveAltitude += altitudeDifference.positive
            totalDistance += newEvent.distanceDifference(to: lastEvent)
        }
        events.append(newEvent)
        switch type {
        case .locationUpdate:
            totalTimeActive = currentTimeActive
            lastActiveDate = Date()
        case .pause, .end:
            totalTimeActive = currentTimeActive
            lastActiveDate = nil
        case .resume, .start:
            lastActiveDate = Date()
        }
    }
    
    func routeImage(rect: CGRect) -> UIImage? {
        let laps = List<WorkoutLap>()
        laps.append(self)
        return UIImage.routeImage(rect: rect, laps: laps)
    }
    
}

extension WorkoutLap {
    
    func toCSV() -> String {
        var csv = ""
        if let startDate = startDate, let endDate = endDate {
            csv += "\(startDate.timeIntervalSince1970),\(endDate.timeIntervalSince1970)"
        } else {
            csv += ","
        }
        csv += ",\(netAltitude),\(totalPositiveAltitude),\(totalDistance),\(totalTimeActive)\n"
        csv += "latitude,longitude,floor,horizontal​Accuracy,vertical​Accuracy,course,speed,distanceTraveled,heartRate,type\n"
        var index = 1
        for event in self.events {
            csv += "\(index),\(event.toCSV())"
            index += 1
        }
        return csv
    }
    
    func toJSON() -> [String: Any?] {
        var eventsJSON: [[String: Any?]] = []
        for event in self.events {
            eventsJSON.append(event.toJSON())
        }
        return [
            "startDateTimestamp": self.startDate?.timeIntervalSince1970 ?? 0,
            "endDateTimestamp": self.endDate?.timeIntervalSince1970 ?? 0,
            "netAltitude": self.netAltitude,
            "totalPositiveAltitude": self.netAltitude,
            "totalDistance": self.netAltitude,
            "totalTimeActive": self.netAltitude,
            "events": eventsJSON,
        ]
    }
    
}
