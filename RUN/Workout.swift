//
//  Workout.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift
import CoreLocation

class Workout: Object {

    dynamic var startDate: Date!
    dynamic var endDate: Date?
    dynamic var totalDistance: Double = 0
    dynamic var totalTimeActive: Double = 0
    var locations = List<Location>()

    convenience init(startDate: Date) {
        self.init()
        self.startDate = startDate
    }
    
    func addLocation(_ location: CLLocation, startsNewSegment: Bool) {
        locations.append(Location(location: location, startsNewSegment: startsNewSegment))
    }
    
}
