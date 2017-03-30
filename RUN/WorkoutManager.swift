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
    
    let speechManager = SpeechManager()
    let locationManager = CLLocationManager()
    
    var workout: Workout?
    private var timer: Timer?
    
    weak var delegate: WorkoutManagerDelegate?
    
    private var lastActiveLocation: CLLocation?
    private var lastActiveDate: Date?
    private (set) var state: WorkoutState = .none {
        didSet {
            delegate?.workoutManagerDidChangeState(self, state: state)
        }
    }
    
    private (set) var timeElapsed: TimeInterval = 0
    var currentTimeElapsed: TimeInterval {
        var currentTimeElapsed = timeElapsed
        if let lastActiveDate = lastActiveDate, lastActiveDate.timeIntervalSinceNow < 0 {
            currentTimeElapsed += -lastActiveDate.timeIntervalSinceNow
        }
        return currentTimeElapsed
    }
    private (set) var distanceTraveled: CLLocationDistance = 0
    private (set) var netElevation: CLLocationDistance = 0
    private (set) var totalPositiveElevation: CLLocationDistance = 0
    //
    private (set) var nextDistanceUpdate: CLLocationDistance = 0
    private (set) var nextTimeUpdate: TimeInterval = 0
    
    convenience init(delegate: WorkoutManagerDelegate) {
        self.init()
        // assume already has permissions
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        self.delegate = delegate
    }
    
    fileprivate func addLocationUpdate(_ location: CLLocation) {
        guard state == .running else { return }
        workout?.addEvent(location, type: .locationUpdate)
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
        updateTimeElapsed()
        updateDistanceTraveled()
    }
    
    var statusText: String {
        return "\(currentTimeElapsed.spoken()), \(Utils.distanceString(meters: distanceTraveled))"
    }
    
    func updateTimeElapsed() {
        guard workout != nil else { return }
        delegate?.workoutManagerDidChangeTime(self, timeElapsed: currentTimeElapsed)
        if nextTimeUpdate > 0 && currentTimeElapsed > nextTimeUpdate {
            print("updating time")
            speechManager.speak(statusText)
            nextTimeUpdate += Settings.audioUpdateTime
        }
    }
    
    func updateDistanceTraveled() {
        guard let workout = workout, let location = locationManager.location else { return }
        delegate?.workoutManagerDidChangeDistance(self, distanceTraveled: distanceTraveled)
        if nextDistanceUpdate > 0 && distanceTraveled > nextDistanceUpdate {
            // TODO fix laps workout.addEvent(location, type: .lap)
            print("updating distance")
            speechManager.speak(statusText)
            nextDistanceUpdate += Settings.audioUpdateDistance
        }
    }
    
    func start(_ workout: Workout) {
        self.workout = workout
        speechManager.playWhiteNoise()
        Settings.audioUpdateTime = 15
        nextTimeUpdate = Settings.audioUpdateTime
        nextDistanceUpdate = Settings.audioUpdateDistance
        resume()
    }
    
    func resume() {
        guard let workout = workout, let location = locationManager.location else { return }
        workout.addEvent(location, type: .resume)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WorkoutManager.timerFired(_:)), userInfo: nil, repeats: true)
        lastActiveDate = Date()
        state = .running
    }
    
    func pause() {
        guard let workout = workout, let location = locationManager.location else { return }
        workout.addEvent(location, type: .pause)
        timer?.invalidate()
        timeElapsed = currentTimeElapsed // lock it in
        lastActiveLocation = nil
        lastActiveDate = nil
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
        completedWorkout?.totalTimeActive = currentTimeElapsed
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
        netElevation = 0
        totalPositiveElevation = 0
        nextDistanceUpdate = 0
        nextTimeUpdate = 0
    }

}

extension WorkoutManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ususally just one location but could be multiple
        for location in locations {
            addLocationUpdate(location)
        }
        if let currentLocation = locations.last {
            delegate?.workoutManagerDidMove(self, to: currentLocation)
        }
        updateTimeElapsed()
        updateDistanceTraveled()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // maybe pause?
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // maybe resume?
    }
    
}
