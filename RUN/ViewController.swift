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
    @IBOutlet weak var workoutsView: UIView!
    @IBOutlet weak var workoutsViewOverlay: UIView!
    @IBOutlet weak var centerActionView: UIView!
    @IBOutlet weak var settingsActionView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var workoutStatsView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggleWorkoutButton: UIButton!
    @IBOutlet weak var endWorkoutButton: UIButton!
    @IBOutlet weak var workoutsViewContraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewHeightConstraint: NSLayoutConstraint!
    weak var workoutsViewController: WorkoutsViewController?
    weak var settingsViewController: SettingsViewController?
    
    var actionViews: [UIView] {
        return [centerActionView, settingsActionView]
    }
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
    
    var polyline: GMSPolyline?
    
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

        setupView(.none, animated: false)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        workoutManager.delegate = self
        timeLabel.text = nil
        distanceLabel.text = nil
        distanceUnitsLabel.text = nil
        registerForThemeChange()
        
        let wPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.workoutsViewPanned(_:)))
        wPanGestureRecognizer.delegate = self
        workoutsView.addGestureRecognizer(wPanGestureRecognizer)
        
        let sPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.settingsViewPanned(_:)))
        sPanGestureRecognizer.delegate = self
        settingsView.addGestureRecognizer(sPanGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let size = settingsViewController?.preferredViewSize {
            settingsViewHeightConstraint.constant = min(view.bounds.height, size.height)
        }
    }
    
    override func configureTheme() {
        let theme = Settings.theme
        if let styleURL = Bundle.main.url(forResource: theme.mapStyle, withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedWorkouts" {
            if let nc = segue.destination as? UINavigationController,
                let vc = nc.childViewControllers.first as? WorkoutsViewController {
                vc.delegate = self
                workoutsViewController = vc
            }
        } else if segue.identifier == "embedSettings" {
            if let vc = segue.destination as? SettingsViewController {
                vc.delegate = self
                settingsViewController = vc
            }
        }
    }
    
    func updateView() {
        if state == .none {
            if isShowingWorkoutsView {
                workoutsViewOverlay.isUserInteractionEnabled = true
                for actionView in actionViews {
                    actionView.isUserInteractionEnabled = false
                }
            } else {
                workoutsViewOverlay.isUserInteractionEnabled = false
                for actionView in actionViews {
                    actionView.isUserInteractionEnabled = true
                }
            }
            for actionView in actionViews {
                actionView.alpha = percentShowingWorkoutsView
            }
            workoutsViewController?.tableView?.panGestureRecognizer.isEnabled = isShowingWorkoutsView
            workoutsViewOverlay.alpha = 1 - percentShowingWorkoutsView
        }
        settingsViewController?.tableView?.panGestureRecognizer.isEnabled = isShowingSettingsView
        //workoutStatsView.alpha = percentShowingworkoutsView
    }

    func prepareTransitionState(_ state: State) {
        switch state {
        case .none:
            for actionView in actionViews {
                actionView.isHidden = false
            }
            toggleWorkoutButton.isHidden = false
        case .live:
            for actionView in actionViews {
                actionView.isHidden = false
            }
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
            //workoutViewContraint.constant = workoutViewHiddenConstant
            for actionView in actionViews {
                actionView.alpha = 1
            }
            workoutStatsView.alpha = 0
        case .live:
            workoutsViewContraint.constant = workoutsViewHiddenConstant
            //workoutViewContraint.constant = workoutViewHiddenConstant
            for actionView in actionViews {
                actionView.alpha = 1
            }
            workoutStatsView.alpha = 1
        case .past:
            workoutsViewContraint.constant = workoutsViewDefaultConstant
            //workoutViewContraint.constant = workoutViewDefaultConstant
            workoutStatsView.alpha = 1
            for actionView in actionViews {
                actionView.alpha = 0
            }
        }
        settingsViewConstraint.constant = settingsViewHiddenConstant
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
            for actionView in actionViews {
                actionView.isHidden = true
            }
            endWorkoutButton.isHidden = true
            toggleWorkoutButton.isHidden = true
            //endWorkoutButton.alpha = 0
            //toggleWorkoutButton.alpha = 0
        }
    }
    
    func setupView(_ state: State, animated: Bool) {
        self.state = state
        prepareTransitionState(state)
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.transitionState(state)
                self.updateView()
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.finalizeState(state)
                    self.updateView()
                }
            }
        } else {
            transitionState(state)
            finalizeState(state)
            updateView()
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
            workoutsViewController?.show(workout)
        }
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        workoutManager.pause()
        UIView.animate(withDuration: 0.25, animations: {
            self.settingsViewConstraint.constant = self.settingsViewFullConstant
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
                self.updateView()
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
            toggleWorkoutButton.setTitle("START RUN", for: .normal)
            endWorkoutButton.isHidden = true
        case .paused:
            toggleWorkoutButton.setTitle("RESUME RUN", for: .normal)
            endWorkoutButton.isHidden = false
        case .running:
            toggleWorkoutButton.setTitle("PAUSE RUN", for: .normal)
            endWorkoutButton.isHidden = true
        }
    }
    
}

extension ViewController: WorkoutsViewControllerDelegate {
    
    var workoutsViewDefaultConstant: CGFloat {
        return view.bounds.height - 64 - 20
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
            print(panGesture.velocity(in: view))
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if (self.workoutsViewContraint.constant < (self.workoutsViewFullConstant + self.workoutsViewHiddenConstant)/4) {
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
    
    func showWorkout(_ workout: Workout) {
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
                newPolyline.strokeWidth = 4
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
    
    func workoutsViewControllerDidClose(_ vc: WorkoutsViewController, workout: Workout?) {
        setupView(.none, animated: true)
    }
    
}

extension ViewController: SettingsViewControllerDelegate {
    
    var settingsViewHiddenConstant: CGFloat {
        return -20
    }
    var settingsViewFullConstant: CGFloat {
        return settingsViewHeightConstraint.constant - 28
    }
    var isShowingSettingsView: Bool {
        return settingsViewConstraint.constant == settingsViewFullConstant
    }
    
    func settingsViewControllerTappedClose(_ vc: SettingsViewController) {
        UIView.animate(withDuration: 0.25, animations: {
            self.settingsViewConstraint.constant = self.settingsViewHiddenConstant
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
            var newConstant = settingsViewConstraint.constant + panGesture.translation(in: view).y
            newConstant = min(newConstant, settingsViewFullConstant)
            newConstant = max(newConstant, settingsViewHiddenConstant)
            settingsViewConstraint.constant = newConstant
            updateView()
            panGesture.setTranslation(.zero, in: view)
            break
        case .ended:
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if (self.settingsViewConstraint.constant < (self.settingsViewFullConstant + self.settingsViewHiddenConstant)/2) {
                    self.settingsViewConstraint.constant = self.settingsViewHiddenConstant
                } else {
                    self.settingsViewConstraint.constant = self.settingsViewFullConstant
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

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let tableView = workoutsViewController?.tableView,
            otherGestureRecognizer == tableView.panGestureRecognizer {
            let translation = tableView.panGestureRecognizer.translation(in: tableView)
            if translation.y > 0 && tableView.contentOffset.y <= 0 {
                return true
            } else {
                return !tableView.panGestureRecognizer.isEnabled
            }
        } else if let tableView = settingsViewController?.tableView,
            otherGestureRecognizer == tableView.panGestureRecognizer {
            let translation = tableView.panGestureRecognizer.translation(in: tableView)
            if translation.y < 0 && (tableView.contentOffset.y + tableView.bounds.height) >= tableView.contentSize.height {
                return true
            } else {
                return !tableView.panGestureRecognizer.isEnabled
            }
        }
        return false
    }
    
}
