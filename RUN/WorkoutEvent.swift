//
//  Location.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift
import CoreLocation

class WorkoutEvent: Object {
    
    enum WorkoutEventType: Int {
        case locationUpdate, pause, resume
    }

    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var floor: Int = 0
    dynamic var altitude: Double = 0
    dynamic var horizontal​Accuracy: Double = 0
    dynamic var vertical​Accuracy: Double = 0
    dynamic var course: Double = 0
    dynamic var speed: Double = 0
    dynamic var distanceTraveled: Double = 0
    dynamic var heartRate: Double = 0
    dynamic var timestamp: Date!
    dynamic var type: Int = 0
    
    var workoutEventType: WorkoutEventType {
        return WorkoutEventType(rawValue: type) ?? .locationUpdate
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    convenience init(location: CLLocation, lastEvent: WorkoutEvent?, heartRate: Double = 0, type: WorkoutEventType) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.floor = location.floor?.level ?? 0
        self.altitude = location.altitude
        self.horizontal​Accuracy = location.horizontalAccuracy
        self.vertical​Accuracy = location.verticalAccuracy
        self.course = location.course
        self.speed = location.speed
        self.timestamp = location.timestamp
        self.distanceTraveled = distanceDifference(to: lastEvent)
        self.heartRate = heartRate
        self.type = type.rawValue
    }
    
    func altitudeDifference(to workoutEvent: WorkoutEvent) -> (positive: Double, net: Double) {
        let altitudeChange = self.altitude - workoutEvent.altitude
        var positive: Double = 0
        if altitudeChange > 0 {
            positive = altitudeChange
        }
        return (positive, altitudeChange)
    }
    
    func timeDifference(to workoutEvent: WorkoutEvent) -> TimeInterval {
        return timestamp.timeIntervalSince(workoutEvent.timestamp)
    }
    
    func distanceDifference(to workoutEvent: WorkoutEvent?) -> CLLocationDistance {
        guard let workoutEvent = workoutEvent else {
            return 0
        }
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: CLLocation(latitude: workoutEvent.latitude, longitude: workoutEvent.longitude))
    }
    
}
