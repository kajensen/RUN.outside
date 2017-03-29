//
//  ViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/23/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift

class ViewController: UIViewController {
    
    enum State {
        case none, live, past
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var workoutsViewOverlay: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var workoutStatsView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggleWorkoutButton: UIButton!
    @IBOutlet weak var endWorkoutButton: UIButton!
    @IBOutlet weak var workoutsViewContraint: NSLayoutConstraint!
    @IBOutlet weak var workoutViewContraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewContraint: NSLayoutConstraint!
    weak var workoutViewController: WorkoutViewController?
    weak var workoutsViewController: WorkoutsViewController?
    weak var settingsViewController: SettingsViewController?
    
    var polyline: GMSPolyline?
    
    var defaultViews: [UIView?] {
        return [workoutsViewOverlay]
    }
    var workoutViews: [UIView?] {
        return [workoutStatsView]
    }
    var selectedWorkout: Workout?
    lazy var workoutManager: WorkoutManager = {
        return WorkoutManager(delegate: self)
    }()
    
    var state: State = .none {
        didSet {
            switch state {
            case .none:
                resetMap(true)
            default:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let styleURL = Bundle.main.url(forResource: "map_mirkwood", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        setupView(.none, animated: false)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        workoutManager.delegate = self
        timeLabel.text = nil
        distanceLabel.text = nil
        distanceUnitsLabel.text = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedWorkouts" {
            if let vc = segue.destination as? WorkoutsViewController {
                vc.delegate = self
                workoutsViewController = vc
            }
        } else if segue.identifier == "embedSettings" {
            if let vc = segue.destination as? SettingsViewController {
                vc.delegate = self
                settingsViewController = vc
            }
        } else if segue.identifier == "embedWorkout" {
            if let vc = segue.destination as? WorkoutViewController {
                vc.delegate = self
                workoutViewController = vc
            }
        }
    }
    
    func updateView() {
        guard state == .none else { return }
        if isShowingWorkoutsView {
            workoutsViewOverlay.isUserInteractionEnabled = true
            actionView.isUserInteractionEnabled = false
        } else {
            workoutsViewOverlay.isUserInteractionEnabled = false
            actionView.isUserInteractionEnabled = true
        }
        actionView.alpha = percentShowingWorkoutsView
        //workoutStatsView.alpha = percentShowingworkoutsView
        workoutsViewOverlay.alpha = 1 - percentShowingWorkoutsView
    }

    func prepareTransitionState(_ state: State) {
        switch state {
        case .none:
            actionView.isHidden = false
            toggleWorkoutButton.isHidden = false
        case .live:
            actionView.isHidden = false
            workoutStatsView.isHidden = false
            toggleWorkoutButton.isHidden = false
        case .past:
            workoutStatsView.isHidden = false
        }
    }
    
    func transitionState(_ state: State) {
        switch state {
        case .none:
            workoutsViewContraint.constant = workoutsViewDefaultConstant
            workoutViewContraint.constant = workoutViewHiddenConstant
            actionView.alpha = 1
            workoutStatsView.alpha = 0
        case .live:
            workoutsViewContraint.constant = workoutsViewHiddenConstant
            workoutViewContraint.constant = workoutViewHiddenConstant
            actionView.alpha = 1
            workoutStatsView.alpha = 1
        case .past:
            workoutsViewContraint.constant = workoutsViewHiddenConstant
            workoutViewContraint.constant = workoutViewDefaultConstant
            workoutStatsView.alpha = 1
            actionView.alpha = 0
        }
        settingsViewContraint.constant = settingsViewHiddenConstant
        workoutsViewOverlay.alpha = 1 - percentShowingWorkoutsView
    }
    
    func finalizeState(_ state: State) {
        switch state {
        case .none:
            workoutStatsView.isHidden = true
            endWorkoutButton.isHidden = true
            //endWorkoutButton.alpha = 0
        case .live:
            endWorkoutButton.isHidden = true
            //endWorkoutButton.alpha = 0
        case .past:
            actionView.isHidden = true
            endWorkoutButton.isHidden = true
            toggleWorkoutButton.isHidden = true
            //endWorkoutButton.alpha = 0
            //toggleWorkoutButton.alpha = 0
        }
    }
    
    func setupView(_ state: State, animated: Bool) {
        self.state = state
        prepareTransitionState(state)
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.transitionState(state)
            self.updateView()
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
                self.finalizeState(state)
                self.updateView()
            }
        }
    }
    
    func resetMap(_ center: Bool) {
        mapView.clear()
        if center {
            centerMapOnUserLocation()
        }
    }
    
}

extension ViewController {

    @IBAction func toggleWorkoutTapped(_ sender: Any) {
        if workoutManager.workout == nil {
            startWorkout()
        } else {
            workoutManager.toggle()
        }
    }
    
    func startWorkout() {
        setupView(.live, animated: true)
        workoutManager.start(Workout(startDate: Date()))
    }
    
    @IBAction func endWorkoutTapped(_ sender: Any) {
        if let workout = workoutManager.end() {
            let realm = try? Realm()
            try? realm?.write {
                realm?.add(workout)
            }
            showWorkout(workout)
        }
    }
    
    func showWorkout(_ workout: Workout) {
        workoutViewController?.workout = workout
        setupView(.past, animated: true)
        polyline = nil
        resetMap(false)
        var bounds = GMSCoordinateBounds()
        var previousLocation: Location?
        for location in workout.locations {
            if let polyline = polyline,
                let previousLocation = previousLocation, !location.startsNewSegment {
                let mutablePath: GMSMutablePath
                if let path = polyline.path {
                    mutablePath = GMSMutablePath(path: path)
                } else {
                    mutablePath = GMSMutablePath()
                }
                mutablePath.add(location.coordinate)
                polyline.path = mutablePath
                var spans = polyline.spans ?? []
                let style = GMSStrokeStyle.gradient(from: previousLocation.speed.color, to: location.speed.color)
                let span = GMSStyleSpan(style: style)
                spans.append(span)
                polyline.spans = spans
                polyline.map = mapView
            } else {
                let path = GMSMutablePath()
                path.add(location.coordinate)
                let newPolyline = GMSPolyline(path: path)
                newPolyline.map = mapView
                newPolyline.spans = [GMSStyleSpan(color: CLLocationSpeed(location.speed).color)]
                polyline = newPolyline
            }
            previousLocation = location
            bounds = bounds.includingCoordinate(location.coordinate)
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
        timeLabel.text = TimeInterval(workout.totalTimeActive).formatted()
        let distanceString = Utils.distanceString(meters: workout.totalDistance).components(separatedBy: " ")
        distanceLabel.text = distanceString.first
        distanceUnitsLabel.text = distanceString.last?.uppercased()
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        workoutManager.pause()
        UIView.animate(withDuration: 0.25, animations: {
            self.settingsViewContraint.constant = self.settingsViewFullConstant
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
            }
        }
    }
    
    @IBAction func centerMapTapped(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    func centerMapOnUserLocation() {
        guard let location = CLLocationManager().location else { return }
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 18)
        mapView.camera = camera
    }
    
}

extension ViewController: WorkoutManagerDelegate {
    
    func workoutManagerDidChangeTime(_ workoutManager: WorkoutManager, timeElapsed: TimeInterval) {
        timeLabel.text = timeElapsed.formatted()
    }

    func workoutManagerDidChangeDistance(_ workoutManager: WorkoutManager, distanceTraveled: CLLocationDistance) {
        let distanceString = Utils.distanceString(meters: distanceTraveled).components(separatedBy: " ")
        distanceLabel.text = distanceString.first
        distanceUnitsLabel.text = distanceString.last?.uppercased()
    }
    
    func workoutManagerDidMove(_ workoutManager: WorkoutManager, to location: CLLocation) {
        switch state {
        case .live, .none:
            if workoutManager.state != .paused {
                mapView.animate(toLocation: location.coordinate)
            }
        default:
            break
        }
        workoutsViewController?.updateWeatherIfNeeded(coordinate: location.coordinate)
    }
    
    func workoutManagerDidUpdate(_ workoutManager: WorkoutManager, from originalLocation: CLLocation?, to location: CLLocation) {
        if let polyline = polyline, let originalLocation = originalLocation {
            let mutablePath: GMSMutablePath
            if let path = polyline.path {
                mutablePath = GMSMutablePath(path: path)
            } else {
                mutablePath = GMSMutablePath()
            }
            mutablePath.add(location.coordinate)
            polyline.path = mutablePath
            var spans = polyline.spans ?? []
            let style = GMSStrokeStyle.gradient(from: originalLocation.speed.color, to: location.speed.color)
            let span = GMSStyleSpan(style: style)
            spans.append(span)
            polyline.spans = spans
            polyline.map = mapView
        } else {
            addNewSegment(location)
        }

    }
    
    func addNewSegment(_ location: CLLocation) {
        let path = GMSMutablePath()
        path.add(location.coordinate)
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
        polyline.spans = [GMSStyleSpan(color: location.speed.color)]
        self.polyline = polyline
    }
    
    func workoutManagerDidChangeState(_ workoutManager: WorkoutManager, state: WorkoutManager.WorkoutState) {
        switch state {
        case .none:
            toggleWorkoutButton.setTitle("Start Workout", for: .normal)
            endWorkoutButton.isHidden = true
        case .paused:
            toggleWorkoutButton.setTitle("Resume Workout", for: .normal)
            endWorkoutButton.isHidden = false
        case .running:
            toggleWorkoutButton.setTitle("Pause Workout", for: .normal)
            endWorkoutButton.isHidden = true
        }
    }
    
}

extension ViewController: WorkoutsViewControllerDelegate {
    
    var workoutsViewDefaultConstant: CGFloat {
        return view.bounds.height - 100
    }
    var workoutsViewHiddenConstant: CGFloat {
        return view.bounds.height
    }
    var workoutsViewFullConstant: CGFloat {
        return 0
    }
    var isShowingWorkoutsView: Bool {
        return workoutsViewContraint.constant == workoutsViewFullConstant
    }
    var percentShowingWorkoutsView: CGFloat {
        return workoutsViewContraint.constant/workoutsViewDefaultConstant
    }
    
    func workoutsViewPanned(_ panGesture: UIPanGestureRecognizer) {
        switch (panGesture.state) {
        case .began:
            break
        case .changed:
            var newConstant = workoutsViewContraint.constant + panGesture.translation(in: view).y
            newConstant = min(newConstant, workoutsViewDefaultConstant)
            newConstant = max(newConstant, workoutsViewFullConstant)
            workoutsViewContraint.constant = newConstant
            updateView()
            panGesture.setTranslation(.zero, in: view)
            break
        case .ended:
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if (self.workoutsViewContraint.constant < (self.workoutsViewFullConstant + self.workoutsViewHiddenConstant)/2) {
                    self.workoutsViewContraint.constant = self.workoutsViewFullConstant
                } else {
                    self.workoutsViewContraint.constant = self.workoutsViewDefaultConstant
                }
                self.updateView()
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.updateView()
                }
            }
            break
        default:
            break
        }
    }
    
    func workoutsViewControllerDidSelect(_ vc: WorkoutsViewController, workout: Workout) {
        showWorkout(workout)
    }
    
}

extension ViewController: WorkoutViewControllerDelegate {
    
    var workoutViewDefaultConstant: CGFloat {
        return view.bounds.height - 100
    }
    var workoutViewHiddenConstant: CGFloat {
        return view.bounds.height
    }
    var workoutViewFullConstant: CGFloat {
        return view.bounds.height - 200
    }
    
    func workoutViewControllerTappedClose(_ vc: WorkoutViewController) {
        selectedWorkout = nil
        setupView(.none, animated: true)
    }
    
    func workoutViewPanned(_ panGesture: UIPanGestureRecognizer) {
        switch (panGesture.state) {
        case .began:
            break
        case .changed:
            var newConstant = workoutViewContraint.constant + panGesture.translation(in: view).y
            newConstant = min(newConstant, workoutViewDefaultConstant)
            newConstant = max(newConstant, workoutViewFullConstant)
            workoutViewContraint.constant = newConstant
            updateView()
            panGesture.setTranslation(.zero, in: view)
            break
        case .ended:
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if (self.workoutViewContraint.constant < (self.workoutViewFullConstant + self.workoutViewHiddenConstant)/2) {
                    self.workoutViewContraint.constant = self.workoutViewFullConstant
                } else {
                    self.workoutViewContraint.constant = self.workoutViewDefaultConstant
                }
                self.updateView()
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.updateView()
                }
            }
            break
        default:
            break
        }
    }
    
}

extension ViewController: SettingsViewControllerDelegate {
    
    var settingsViewHiddenConstant: CGFloat {
        return -20
    }
    var settingsViewFullConstant: CGFloat {
        return 220
    }
    
    func settingsViewControllerTappedClose(_ vc: SettingsViewController) {
        UIView.animate(withDuration: 0.25, animations: {
            self.settingsViewContraint.constant = self.settingsViewHiddenConstant
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
            }
        }
    }
    
    func settingsViewPanned(_ panGesture: UIPanGestureRecognizer) {
        switch (panGesture.state) {
        case .began:
            break
        case .changed:
            var newConstant = settingsViewContraint.constant + panGesture.translation(in: view).y
            newConstant = min(newConstant, settingsViewFullConstant)
            newConstant = max(newConstant, settingsViewHiddenConstant)
            settingsViewContraint.constant = newConstant
            updateView()
            panGesture.setTranslation(.zero, in: view)
            break
        case .ended:
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if (self.settingsViewContraint.constant < (self.settingsViewFullConstant + self.settingsViewHiddenConstant)/2) {
                    self.settingsViewContraint.constant = self.settingsViewHiddenConstant
                } else {
                    self.settingsViewContraint.constant = self.settingsViewFullConstant
                }
                self.updateView()
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.updateView()
                }
            }
            break
        default:
            break
        }
    }
    
}

extension ViewController: GMSMapViewDelegate {
    // TODO
}
