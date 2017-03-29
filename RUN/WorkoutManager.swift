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
    func workoutManagerDidMove(_ workoutManager: WorkoutManager, to location: CLLocation)
    func workoutManagerDidUpdate(_ workoutManager: WorkoutManager, from originalLocation: CLLocation?, to location: CLLocation)
    func workoutManagerDidChangeTime(_ workoutManager: WorkoutManager, timeElapsed: TimeInterval)
    func workoutManagerDidChangeDistance(_ workoutManager: WorkoutManager, distanceTraveled: CLLocationDistance)
    func workoutManagerDidChangeState(_ workoutManager: WorkoutManager, state: WorkoutManager.WorkoutState)
}

class WorkoutManager: NSObject {
    
    enum WorkoutState {
        case none, running, paused
    }
    
    let locationManager = CLLocationManager()
    var workout: Workout?
    private var timer: Timer?
    weak var delegate: WorkoutManagerDelegate?
    private var lastActiveLocation: CLLocation?
    private (set) var state: WorkoutState = .none {
        didSet {
            delegate?.workoutManagerDidChangeState(self, state: state)
        }
    }
    
    var timeElapsed: TimeInterval = 0 {
        didSet {
            delegate?.workoutManagerDidChangeTime(self, timeElapsed: timeElapsed)
        }
    }
    var distanceTraveled: CLLocationDistance = 0 {
        didSet {
            delegate?.workoutManagerDidChangeDistance(self, distanceTraveled: distanceTraveled)
        }
    }
    var netElevation: CLLocationDistance = 0
    var totalPositiveElevation: CLLocationDistance = 0
    
    convenience init(delegate: WorkoutManagerDelegate) {
        self.init()
        // assume already has permissions
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        self.delegate = delegate
    }
    
    fileprivate func addLocation(_ location: CLLocation) {
        guard state == .running else { return }
        let startsNewSegment = lastActiveLocation == nil
        workout?.addLocation(location, startsNewSegment: startsNewSegment)
        if let lastActiveLocation = lastActiveLocation {
            distanceTraveled += lastActiveLocation.distance(from: location)
            let elevationDiff = location.altitude - lastActiveLocation.altitude
            if elevationDiff > 0 {
                totalPositiveElevation += elevationDiff
            }
            netElevation += elevationDiff
        }
        delegate?.workoutManagerDidUpdate(self, from: lastActiveLocation, to: location)
        lastActiveLocation = location
    }
    
    func timerFired(_ sender: Any) {
        timeElapsed += 0.1
    }
    
    func start(_ workout: Workout) {
        self.workout = workout
        resume()
    }
    
    func resume() {
        guard let _ = workout else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WorkoutManager.timerFired(_:)), userInfo: nil, repeats: true)
        state = .running
    }
    
    func pause() {
        guard let _ = workout else { return }
        timer?.invalidate()
        lastActiveLocation = nil
        state = .paused
    }
    
    func toggle() {
        guard let _ = workout else { return }
        if state == .paused {
            resume()
        } else if state == .running {
            pause()
        }
    }
    
    func end() -> Workout? {
        state = .none
        let completedWorkout = self.workout
        completedWorkout?.endDate = Date()
        completedWorkout?.totalTimeActive = timeElapsed
        completedWorkout?.totalDistance = distanceTraveled
        completedWorkout?.totalPositiveElevation = totalPositiveElevation
        completedWorkout?.netElevation = netElevation
        reset()
        return completedWorkout
    }
    
    func reset() {
        workout = nil
        timeElapsed = 0
        distanceTraveled = 0
    }

}


extension CLLocationSpeed {
    var color: UIColor {
        if self > 3.5 {
            return UIColor.green
        } else if self > 3 {
            return UIColor.yellow
        } else {
            return UIColor.red
        }
    }
}

extension WorkoutManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ususally just one location but could be multiple
        for location in locations {
            addLocation(location)
        }
        if let currentLocation = locations.last {
            delegate?.workoutManagerDidMove(self, to: currentLocation)
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // maybe pause?
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // maybe resume?
    }
    
}
