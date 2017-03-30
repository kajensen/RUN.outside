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
        case locationUpdate, pause, resume, lap
    }

    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var floor: Int = 0
    dynamic var horizontal​Accuracy: Double = 0
    dynamic var vertical​Accuracy: Double = 0
    dynamic var course: Double = 0
    dynamic var speed: Double = 0
    dynamic var timestamp: Date!
    dynamic var type: Int = 0
    
    var workoutEventType: WorkoutEventType {
        return WorkoutEventType(rawValue: type) ?? .locationUpdate
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    convenience init(location: CLLocation, type: WorkoutEventType) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.floor = location.floor?.level ?? 0
        self.horizontal​Accuracy = location.horizontalAccuracy
        self.vertical​Accuracy = location.verticalAccuracy
        self.course = location.course
        self.speed = location.speed
        self.timestamp = location.timestamp
        self.type = type.rawValue
    }
    
}
