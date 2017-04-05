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

class MapViewController: UIViewController {
    
    static let storyboardId = "MapViewController"
    
    enum State {
        case none, live, past
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var workoutsView: UIView!
    @IBOutlet weak var workoutsViewOverlay: UIView!
    @IBOutlet weak var settingsViewOverlay: UIView!
    @IBOutlet weak var centerActionView: BGView!
    @IBOutlet weak var settingsActionView: BGView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var workoutStatsView: BGView!
    @IBOutlet weak var statusView: BGView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var toggleWorkoutButton: UIButton!
    @IBOutlet weak var endWorkoutButton: UIButton!
    @IBOutlet weak var workoutsViewContraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewHeightConstraint: NSLayoutConstraint!
    weak var workoutsNavigationViewController: WorkoutsNavigationViewController?
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

        workoutsViewContraint.constant = workoutsViewDefaultConstant
        settingsViewConstraint.constant = settingsViewHiddenConstant
        setupView(.none, animated: false)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        workoutManager.delegate = self
        timeLabel.text = nil
        distanceLabel.text = nil
        distanceUnitsLabel.text = nil
        registerForThemeChange()
            
        let wPanGestureRecognizer = RUNPanGestureRecognizer(target: self, action: #selector(MapViewController.workoutsViewPanned(_:)))
        wPanGestureRecognizer.delegate = self
        workoutsView.addGestureRecognizer(wPanGestureRecognizer)
        
        let sPanGestureRecognizer = RUNPanGestureRecognizer(target: self, action: #selector(MapViewController.settingsViewPanned(_:)))
        sPanGestureRecognizer.delegate = self
        settingsView.addGestureRecognizer(sPanGestureRecognizer)
        
        let sTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.settingsViewTapped(_:)))
        settingsViewOverlay.addGestureRecognizer(sTapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let size = settingsViewController?.preferredViewSize {
            settingsViewHeightConstraint.constant = min(view.bounds.height, size.height)
        }
    }
    
    override func configureTheme() {
        let theme = Settings.theme
        distanceLabel.textColor = theme.primaryTextColor
        distanceUnitsLabel.textColor = theme.secondaryTextColor
        statusView.effect = theme.blurEffect
        statusLabel.textColor = theme.secondaryTextColor
        timeLabel.textColor = theme.primaryTextColor
        timeInfoLabel.textColor = theme.secondaryTextColor
        if let styleURL = Bundle.main.url(forResource: theme.mapStyle, withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        centerActionView.effect = theme.blurEffect
        settingsActionView.effect = theme.blurEffect
        workoutStatsView.effect = theme.blurEffect
        toggleWorkoutButton.backgroundColor = theme.greenColor
        endWorkoutButton.backgroundColor = theme.redColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedWorkouts" {
            if let nc = segue.destination as? WorkoutsNavigationViewController,
                let vc = nc.childViewControllers.first as? WorkoutsViewController {
                vc.delegate = self
                workoutsViewController = vc
                workoutsNavigationViewController = nc
            }
        } else if segue.identifier == "embedSettings" {
            if let nc = segue.destination as? UINavigationController,
                let vc = nc.childViewControllers.first as? SettingsViewController {
                vc.delegate = self
                settingsViewController = vc
            }
        }
    }
    
    func updateView() {
        workoutsViewOverlay.isUserInteractionEnabled = isShowingWorkoutsView
        settingsViewOverlay.isUserInteractionEnabled = isShowingSettingsView
        workoutsViewOverlay.alpha = percentShowingWorkoutsView
        settingsViewOverlay.alpha = percentShowingSettingsView
        settingsViewController?.tableView?.panGestureRecognizer.isEnabled = isShowingSettingsView
        workoutsNavigationViewController?.tableView?.panGestureRecognizer.isEnabled = isShowingWorkoutsView
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
        statusView.isHidden = true
    }
    
    func transitionState(_ state: State) {
        switch state {
        case .none:
            for actionView in actionViews {
                actionView.alpha = 1
            }
            workoutStatsView.alpha = 0
        case .live:
            workoutsViewContraint.constant = workoutsViewHiddenConstant
            for actionView in actionViews {
                actionView.alpha = 1
            }
            workoutStatsView.alpha = 1
        case .past:
            workoutStatsView.alpha = 1
            for actionView in actionViews {
                actionView.alpha = 0
            }
        }
        settingsViewConstraint.constant = settingsViewHiddenConstant
        workoutsViewOverlay.alpha = percentShowingWorkoutsView
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
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn], animations: {
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

extension MapViewController {

    @IBAction func toggleWorkoutTapped(_ sender: Any) {
        if workoutManager.workout == nil {
            startWorkout()
        } else {
            workoutManager.toggle()
        }
    }
    
    func startWorkout() {
        setupView(.live, animated: true)
        let _ = workoutManager.start()
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
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn], animations: {
            self.settingsViewConstraint.constant = self.settingsViewFullConstant
            self.updateView()
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
        mapView.animate(to: camera)
    }
    
}

extension MapViewController: WorkoutManagerDelegate {
    
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
    
    func workoutManagerDidUpdate(_ workoutManager: WorkoutManager, from previousEvent: WorkoutEvent?, to newEvent: WorkoutEvent) {
        addEvent(newEvent)//, previousEvent: previousEvent)
    }
    
    func workoutManagerDidChangeState(_ workoutManager: WorkoutManager, state: WorkoutManager.WorkoutState) {
        switch state {
        case .none:
            toggleWorkoutButton.setTitle("START RUN", for: .normal)
            endWorkoutButton.isHidden = true
            statusView.isHidden = true
        case .paused:
            toggleWorkoutButton.setTitle("RESUME RUN", for: .normal)
            endWorkoutButton.isHidden = false
            statusView.isHidden = false
        case .running:
            toggleWorkoutButton.setTitle("PAUSE RUN", for: .normal)
            endWorkoutButton.isHidden = true
            statusView.isHidden = true
        }
    }
    
}

extension MapViewController: WorkoutsViewControllerDelegate {
    
    var workoutsViewDefaultConstant: CGFloat {
        return view.bounds.height - 64 - 20
    }
    var workoutsViewHiddenConstant: CGFloat {
        return view.bounds.height
    }
    var workoutsViewGraphConstant: CGFloat {
        return view.bounds.height - 64 - 200 - 20
    }
    var workoutsViewFullConstant: CGFloat {
        return 0
    }
    var isShowingWorkoutsView: Bool {
        return workoutsViewContraint.constant == workoutsViewFullConstant
    }
    var percentShowingWorkoutsView: CGFloat {
        return (workoutsViewGraphConstant - workoutsViewContraint.constant)/workoutsViewGraphConstant
    }
    
    func workoutsViewPanned(_ panGesture: RUNPanGestureRecognizer) {
        switch (panGesture.state) {
        case .began:
            panGesture.beginningConstant = workoutsViewContraint.constant
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
            let constant: CGFloat
            let isExpanding = (panGesture.beginningConstant - workoutsViewContraint.constant) > 0
            if (workoutsViewContraint.constant < workoutsViewGraphConstant) {
                constant = isExpanding ? workoutsViewFullConstant : workoutsViewGraphConstant
            } else if (workoutsViewContraint.constant < workoutsViewDefaultConstant - 20) {
                constant = isExpanding ? workoutsViewGraphConstant : workoutsViewDefaultConstant
            } else {
                constant = workoutsViewDefaultConstant
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn], animations: {
                self.workoutsViewContraint.constant = constant
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
        print(workout)
        setupView(.past, animated: true)
        polyline = nil
        resetMap(false)
        var bounds = GMSCoordinateBounds()
        var previousEvent: WorkoutEvent?
        for lap in workout.laps {
            for event in lap.events {
                addEvent(event)//, previousEvent: previousEvent)
                previousEvent = event
                bounds = bounds.includingCoordinate(event.coordinate)
            }
        }
        let cameraUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(100, 20, 300, 20))
        mapView.animate(with: cameraUpdate)
        timeLabel.text = TimeInterval(workout.totalTimeActive).formatted()
        let distanceString = Utils.distanceString(meters: workout.totalDistance).components(separatedBy: " ")
        distanceLabel.text = distanceString.first
        distanceUnitsLabel.text = distanceString.last?.uppercased()
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn], animations: {
            self.workoutsViewContraint.constant = self.workoutsViewGraphConstant
            self.updateView()
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
                self.updateView()
            }
        }
    }
    
    func addEvent(_ event: WorkoutEvent) {
        switch event.workoutEventType {
        case .pause:
            polyline = nil
        case .resume:
            let path = GMSMutablePath()
            path.add(event.coordinate)
            let newPolyline = GMSPolyline(path: path)
            newPolyline.strokeWidth = 4
            newPolyline.map = mapView
            newPolyline.spans = [GMSStyleSpan(color: CLLocationSpeed(event.speed).color)]
            polyline = newPolyline
        case .locationUpdate:
            let mutablePath: GMSMutablePath
            if let path = polyline?.path {
                mutablePath = GMSMutablePath(path: path)
            } else {
                mutablePath = GMSMutablePath()
            }
            mutablePath.add(event.coordinate)
            let newPolyline = GMSPolyline(path: mutablePath)
            newPolyline.path = mutablePath
            var spans = newPolyline.spans ?? []
            //let style = GMSStrokeStyle.gradient(from: previousEvent.speed.color, to: event.speed.color)
            //let span = GMSStyleSpan(style: style)
            let span = GMSStyleSpan(color: event.speed.color)
            spans.append(span)
            newPolyline.spans = spans
            newPolyline.map = mapView
            polyline = newPolyline
        }
    }
    
    func workoutsViewControllerDidClose(_ vc: WorkoutsViewController, workout: Workout?) {
        setupView(.none, animated: true)
    }
    
}

extension MapViewController: SettingsViewControllerDelegate {
    
    var settingsViewHiddenConstant: CGFloat {
        return -20
    }
    var settingsViewFullConstant: CGFloat {
        return settingsViewHeightConstraint.constant - 28
    }
    var isShowingSettingsView: Bool {
        return settingsViewConstraint.constant == settingsViewFullConstant
    }
    var percentShowingSettingsView: CGFloat {
        return settingsViewConstraint.constant/settingsViewFullConstant
    }
    
    func settingsViewControllerTappedClose(_ vc: SettingsViewController) {
        closeSettings()
    }
    
    func closeSettings() {
        let constant = settingsViewHiddenConstant
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn], animations: {
            self.settingsViewConstraint.constant = constant
            self.updateView()
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
                self.updateView()
                let _ = self.settingsViewController?.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
    func settingsViewPanned(_ panGesture: RUNPanGestureRecognizer) {
        switch (panGesture.state) {
        case .began:
            panGesture.beginningConstant = workoutsViewContraint.constant
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
            let isContracting = (panGesture.beginningConstant - settingsViewConstraint.constant) > 0
            let constant: CGFloat
            if isContracting {
                constant = settingsViewHiddenConstant
            } else {
                constant = settingsViewFullConstant
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn], animations: {
                self.settingsViewConstraint.constant = constant
                self.updateView()
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                    self.updateView()
                    if isContracting {
                        let _ = self.settingsViewController?.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func settingsViewTapped(_ tapGesture: UITapGestureRecognizer) {
        switch (tapGesture.state) {
        case .ended:
            closeSettings()
            break
        default:
            break
        }
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    
    // TODO
}

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        var shouldRecognize = false
        if let tableView = workoutsNavigationViewController?.tableView,
            otherGestureRecognizer == tableView.panGestureRecognizer {
            let translation = tableView.panGestureRecognizer.translation(in: tableView)
            if translation.y > 0 && tableView.contentOffset.y <= 0 {
                shouldRecognize = true
            } else {
                shouldRecognize = !tableView.panGestureRecognizer.isEnabled
            }
        } else if let tableView = settingsViewController?.tableView,
            otherGestureRecognizer == tableView.panGestureRecognizer {
            let translation = tableView.panGestureRecognizer.translation(in: tableView)
            if translation.y < 0 && (tableView.contentOffset.y + tableView.bounds.height) >= tableView.contentSize.height {
                shouldRecognize = true
            } else {
                shouldRecognize = !tableView.panGestureRecognizer.isEnabled
            }
        }
        return shouldRecognize
    }
    
}
