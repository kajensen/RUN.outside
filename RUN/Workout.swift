//
//  Workout.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift
import CoreLocation
import MapKit
import GoogleMaps

class Workout: Object {
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    dynamic var startDate: Date?
    dynamic var endDate: Date?
    dynamic var netAltitude: Double = 0
    dynamic var totalPositiveAltitude: Double = 0
    dynamic var totalDistance: Double = 0
    dynamic var totalTimeActive: TimeInterval = 0
    private (set) var laps = List<WorkoutLap>()
    
    private (set) var lastActiveDate: Date?
    override static func ignoredProperties() -> [String] {
        return ["lastActiveDate"]
    }
    
    var speed: Double {
        return totalDistance/totalTimeActive
    }
    
    var currentTimeActive: TimeInterval {
        var currentTimeElapsed = totalTimeActive
        if let lastActiveDate = lastActiveDate, lastActiveDate.timeIntervalSinceNow < 0 {
            currentTimeElapsed += -lastActiveDate.timeIntervalSinceNow
        }
        return currentTimeElapsed
    }
    
    var currentLap: WorkoutLap? {
        return laps.last
    }
    
    var title: String? {
        guard let startDate = startDate else { return nil }
        return Workout.dateFormatter.string(from: startDate)
    }
    
    var statusText: String {
        return "\(currentTimeActive.spoken()), \(Utils.longDistanceString(meters: totalDistance))"
    }
    
    convenience init(startDate: Date) {
        self.init()
        self.startDate = startDate
        lastActiveDate = Date()
    }

    func newLap(location: CLLocation) -> (newEvent: WorkoutEvent, previousEvent: WorkoutEvent?, newLap: WorkoutLap, previousLap: WorkoutLap?) {
        currentLap?.end()
        let previousLap = currentLap
        let newLap = WorkoutLap(startDate: Date(), location: location, type: previousLap == nil ? .start : .resume)
        laps.append(newLap)
        let eventUpdate = addEvent(location, type: .resume)
        return (eventUpdate.newEvent, eventUpdate.previousEvent, newLap, previousLap)
    }
    
    func endLap() {
        currentLap?.end()
    }
    
    func endWorkout(location: CLLocation) {
        let _ = addEvent(location, type: .end)
        self.endDate = Date()
    }
    
    func addEvent(_ location: CLLocation, type: WorkoutEvent.WorkoutEventType) -> (newEvent: WorkoutEvent, previousEvent: WorkoutEvent?) {
        let previousEvent = currentLap?.events.last
        let newEvent = WorkoutEvent(location: location, lastEvent: nil, type: type)
        if let lastEvent = currentLap?.events.last, lastEvent.workoutEventType != .pause {
            let altitudeDifference = newEvent.altitudeDifference(to: lastEvent)
            netAltitude += altitudeDifference.net
            totalPositiveAltitude += altitudeDifference.positive
            totalDistance += newEvent.distanceDifference(to: lastEvent)
        }
        currentLap?.addEvent(location, type: type)
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
        return (newEvent, previousEvent)
    }
    
    func routeImage(rect: CGRect) -> UIImage? {
        return UIImage.routeImage(rect: rect, laps: laps)
    }
    
}

extension UIImage {
    
    class func routeImage(rect: CGRect, laps: List<WorkoutLap>) -> UIImage? {
        // TODO: fix me this is inverted horizontal
        var bounds = GMSCoordinateBounds()
        for lap in laps {
            for event in lap.events {
                bounds = bounds.includingCoordinate(event.coordinate)
            }
        }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1)
        context.beginPath()
        
        let minLng = bounds.southWest.longitude
        let maxLng = bounds.northEast.longitude
        let minLat = bounds.southWest.latitude
        let maxLat = bounds.northEast.latitude
        let side = max((maxLng - minLng), (maxLat - minLat))
        let latPadding = (maxLng - minLng) > (maxLat - minLat) ? (maxLng - minLng)/2 : 0
        let lngPadding = (maxLng - minLng) > (maxLat - minLat) ? 0 : (maxLat - minLat)/2
        let mapRect = CGRect(x: minLng - lngPadding, y: minLat - latPadding, width: side, height: side)
        let thumbRect = rect.insetBy(dx: 8, dy: 8)
        for lap in laps {
            for (_, event) in lap.events.enumerated() {
                let coordinate = event.coordinate
                let point = CGPoint(x: maxLng - coordinate.longitude + lngPadding, y: maxLat - coordinate.latitude + latPadding)
                let thumbPoint = point.convert(fromRect: mapRect, toRect: thumbRect)
                if !thumbPoint.x.isNaN && !thumbPoint.y.isNaN {
                    switch event.workoutEventType {
                    case .resume, .pause, .start, .end:
                        context.move(to: thumbPoint)
                    case .locationUpdate:
                        context.addLine(to: thumbPoint)
                    }
                }
            }
        }
        
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension CGPoint {
    func convert(fromRect: CGRect, toRect: CGRect) -> CGPoint {
        return CGPoint(x: (toRect.size.width/fromRect.size.width) * self.x, y: (toRect.size.height/fromRect.size.height) * self.y)
    }
}

extension Workout {
    
    func toCSV() -> String {
        var csv = "Workout,startDateTimestamp,endDateTimestamp,netAltitude,totalPositiveAltitude,totalDistance,totalTimeActive\n"
        if let startDate = startDate, let endDate = endDate {
            csv += ",\(startDate.timeIntervalSince1970),\(endDate.timeIntervalSince1970)"
        } else {
            csv += ",,"
        }
        csv += ",\(netAltitude),\(totalPositiveAltitude),\(totalDistance),\(totalTimeActive)\n"
        var index = 1
        for lap in self.laps {
            csv += "Lap #\(index),\(lap.toCSV())"
            index += 1
        }
        return csv
    }
    
    func toJSON() -> [String: Any?] {
        var lapsJSON: [[String: Any?]] = []
        for lap in self.laps {
            lapsJSON.append(lap.toJSON())
        }
        return [
            "startDateTimestamp": self.startDate?.timeIntervalSince1970 ?? 0,
            "endDateTimestamp": self.endDate?.timeIntervalSince1970 ?? 0,
            "netAltitude": self.netAltitude,
            "totalPositiveAltitude": self.netAltitude,
            "totalDistance": self.netAltitude,
            "totalTimeActive": self.netAltitude,
            "laps": lapsJSON,
        ]
    }
    
}
