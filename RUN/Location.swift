//
//  Location.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift
import CoreLocation

class Location: Object {

    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var floor: Int = 0
    dynamic var horizontal​Accuracy: Double = 0
    dynamic var vertical​Accuracy: Double = 0
    dynamic var course: Double = 0
    dynamic var startsNewSegment: Bool = false
    dynamic var timestamp: Date!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    convenience init(location: CLLocation, startsNewSegment: Bool) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.floor = location.floor?.level ?? 0
        self.horizontal​Accuracy = location.horizontalAccuracy
        self.vertical​Accuracy = location.verticalAccuracy
        self.course = location.course
        self.startsNewSegment = startsNewSegment
        self.timestamp = location.timestamp
    }
    
}
