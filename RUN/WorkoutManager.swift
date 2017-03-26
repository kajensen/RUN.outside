//
//  WorkoutManager.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import CoreLocation

protocol WorkoutManagerDelegate: class {
    func workoutMangerDidStart(_ workoutManager: WorkoutManager, location: CLLocationCoordinate2D, speed: Double)
    func workoutMangerDidAddSegment(_ workoutManager: WorkoutManager, location: CLLocationCoordinate2D, speed: Double)
    func workoutMangerDidChangeTime(_ workoutManager: WorkoutManager, timeElapsed: TimeInterval)
    func workoutMangerDidChangeDistance(_ workoutManager: WorkoutManager, distanceTraveled: CLLocationDistance)
    func workoutMangerDidChangeState(_ workoutManager: WorkoutManager, state: WorkoutManager.WorkoutState)
}

class WorkoutManager: NSObject {
    
    enum WorkoutState {
        case none, running, paused
    }
    
    let locationManager = CLLocationManager()
    private let workout = Workout()
    private var timer: Timer?
    weak var delegate: WorkoutManagerDelegate?
    private var lastActiveLocation: CLLocation?
    private var state: WorkoutState = .none {
        didSet {
            delegate?.workoutMangerDidChangeState(self, state: state)
        }
    }
    
    var timeElapsed: TimeInterval = 0 {
        didSet {
            delegate?.workoutMangerDidChangeTime(self, timeElapsed: timeElapsed)
        }
    }
    var distanceTraveled: CLLocationDistance = 0 {
        didSet {
            delegate?.workoutMangerDidChangeDistance(self, distanceTraveled: distanceTraveled)
        }
    }
    
    convenience init(delegate: WorkoutManagerDelegate) {
        self.init()
        // assume already has permissions
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        self.delegate = delegate
        start()
    }
    
    fileprivate func addLocation(_ location: CLLocation) {
        guard state == .running else { return }
        workout.addLocation(location, startsNewSegment: lastActiveLocation == nil)
        if let lastActiveLocation = lastActiveLocation {
            distanceTraveled += lastActiveLocation.distance(from: location)
        }
        lastActiveLocation = location
    }
    
    func timerFired(_ sender: Any) {
        timeElapsed += 0.1
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WorkoutManager.timerFired(_:)), userInfo: nil, repeats: true)
        state = .running
    }
    
    func pause() {
        timer?.invalidate()
        lastActiveLocation = nil
        state = .paused
    }
    
    func toggle() {
        if state == .paused {
            start()
        } else if state == .running {
            pause()
        }
    }
    
    func end() -> Workout {
        // TODO
        state = .none
        workout.totalTimeActive = timeElapsed
        workout.totalDistance = distanceTraveled
        return workout
    }

}

extension WorkoutManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ususally just one location but could be multiple
        for location in locations {
            addLocation(location)
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // maybe pause?
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // maybe resume?
    }
    
}
