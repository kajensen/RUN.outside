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
    func workoutManagerDidUpdate(_ workoutManager: WorkoutManager, from previousEvent: WorkoutEvent?, to newEvent: WorkoutEvent)
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
    
    private (set) var state: WorkoutState = .none {
        didSet {
            delegate?.workoutManagerDidChangeState(self, state: state)
        }
    }
    /*
    private var lastActiveLocation: CLLocation?

    private (set) var distanceTraveled: CLLocationDistance = 0
    private (set) var netElevation: CLLocationDistance = 0
    private (set) var totalPositiveElevation: CLLocationDistance = 0
 
    
    private var lastActiveDate: Date?
    private (set) var timeElapsed: TimeInterval = 0
    var currentTimeElapsed: TimeInterval {
        var currentTimeElapsed = timeElapsed
        if let lastActiveDate = lastActiveDate, lastActiveDate.timeIntervalSinceNow < 0 {
            currentTimeElapsed += -lastActiveDate.timeIntervalSinceNow
        }
        return currentTimeElapsed
    }*/
    
    private (set) var nextDistanceUpdate: CLLocationDistance = 0
    private (set) var nextTimeUpdate: TimeInterval = 0
    private (set) var nextLap: CLLocationDistance = 0
    
    convenience init(delegate: WorkoutManagerDelegate) {
        self.init()
        // assume already has permissions
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        self.delegate = delegate
    }
    
    fileprivate func addLocationUpdate(_ location: CLLocation) {
        speechManager.speak("update")
        guard let workout = workout, state == .running else { return }
        let update = workout.addEvent(location, type: .locationUpdate)
        delegate?.workoutManagerDidUpdate(self, from: update.previousEvent, to: update.newEvent)
        //lastActiveLocation = location
    }
    
    func timerFired(_ sender: Any) {
        updateTimeElapsed()
        updateDistanceTraveled()
    }
    
    func updateTimeElapsed() {
        guard let workout = workout else { return }
        delegate?.workoutManagerDidChangeTime(self, timeElapsed: workout.currentTimeActive)
        if nextTimeUpdate > 0 && workout.currentTimeActive > nextTimeUpdate {
            print("updating time")
            speechManager.speak(workout.statusText)
            nextTimeUpdate += Settings.audioUpdateTime
        }
    }
    
    func updateDistanceTraveled() {
        guard let workout = workout, let location = locationManager.location else { return }
        delegate?.workoutManagerDidChangeDistance(self, distanceTraveled: workout.totalDistance)
        if nextDistanceUpdate > 0 && workout.totalDistance > nextDistanceUpdate {
            print("updating distance")
            speechManager.speak(workout.statusText)
            nextDistanceUpdate += Settings.audioUpdateDistance
        }
        if nextLap > 0 && workout.totalDistance > nextLap {
            speechManager.speak("new lap")
            print("starting new lap")
            let update = workout.newLap(location: location)
            delegate?.workoutManagerDidUpdate(self, from: update.previousEvent, to: update.newEvent)
            nextLap += Settings.lapDistance
        }
    }
    
    func start() -> Bool {
        guard let location = locationManager.location else {
            return false
        }
        let workout = Workout(startDate: Date())
        let update = workout.newLap(location: location)
        delegate?.workoutManagerDidUpdate(self, from: update.previousEvent, to: update.newEvent)
        self.workout = workout
        speechManager.playWhiteNoise()
        nextTimeUpdate = Settings.audioUpdateTime
        nextDistanceUpdate = Settings.audioUpdateDistance
        nextLap = Settings.lapDistance
        resume(true)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WorkoutManager.timerFired(_:)), userInfo: nil, repeats: true)
        return true
    }
    
    func resume(_ isActuallyStart: Bool = false) {
        guard let workout = workout, let location = locationManager.location else { return }
        speechManager.speak(isActuallyStart ? "start" : "resume")
        let update = workout.addEvent(location, type: .resume)
        delegate?.workoutManagerDidUpdate(self, from: update.previousEvent, to: update.newEvent)
        //lastActiveDate = Date()
        state = .running
    }
    
    func pause() {
        guard let workout = workout, let location = locationManager.location else { return }
        speechManager.speak("pause")
        let update = workout.addEvent(location, type: .pause)
        delegate?.workoutManagerDidUpdate(self, from: update.previousEvent, to: update.newEvent)
        //timeElapsed = currentTimeElapsed // lock it in
        //lastActiveLocation = nil
        //lastActiveDate = nil
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
        speechManager.speak("end")
        state = .none
        let completedWorkout = self.workout
        completedWorkout?.end()
        reset()
        return completedWorkout
    }
    
    func reset() {
        workout = nil
        nextDistanceUpdate = 0
        nextTimeUpdate = 0
        nextLap = 0
        timer?.invalidate()
    }

}

extension WorkoutManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ususally just one location but could be multiple
        for location in locations {
            // make sure its good data, horizontal is more important.
            if location.horizontalAccuracy != -1 && location.horizontalAccuracy < 20 && location.verticalAccuracy < 50 {
                guard let lastActiveDate = workout?.lastActiveDate, lastActiveDate.compare(location.timestamp) == .orderedAscending else {
                    break
                }
                addLocationUpdate(location)
            }
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
