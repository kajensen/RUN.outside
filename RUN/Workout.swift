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
    dynamic var netElevation: Double = 0
    dynamic var totalPositiveElevation: Double = 0
    dynamic var totalDistance: Double = 0
    dynamic var totalTimeActive: Double = 0
    var events = List<WorkoutEvent>()

    var title: String? {
        guard let startDate = startDate else { return nil }
        return Workout.dateFormatter.string(from: startDate)
    }
    
    convenience init(startDate: Date) {
        self.init()
        self.startDate = startDate
    }
    
    func addEvent(_ location: CLLocation, type: WorkoutEvent.WorkoutEventType) {
        events.append(WorkoutEvent(location: location, type: type))
    }
    
    func pathImageForSize(rect: CGRect) -> UIImage? {
        // TODO: fix me this is inverted horizontal
        var bounds = GMSCoordinateBounds()
        for event in events {
            bounds = bounds.includingCoordinate(event.coordinate)
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
        for (_, event) in events.enumerated() {
            let coordinate = event.coordinate
            let point = CGPoint(x: maxLng - coordinate.longitude + lngPadding, y: maxLat - coordinate.latitude + latPadding)
            let thumbPoint = point.convert(fromRect: mapRect, toRect: thumbRect)
            if !thumbPoint.x.isNaN && !thumbPoint.y.isNaN {
                switch event.workoutEventType {
                case .resume:
                    context.move(to: thumbPoint)
                case .locationUpdate:
                    context.addLine(to: thumbPoint)
                default:
                    break
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
