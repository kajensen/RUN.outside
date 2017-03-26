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
    @IBOutlet weak var mainViewOverlay: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var workoutStatsView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggleWorkoutButton: UIButton!
    @IBOutlet weak var endWorkoutButton: UIButton!
    @IBOutlet weak var mainViewContraint: NSLayoutConstraint!
    @IBOutlet weak var workoutViewContraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewContraint: NSLayoutConstraint!
    
    var defaultViews: [UIView?] {
        return [mainViewOverlay]
    }
    var workoutViews: [UIView?] {
        return [workoutStatsView]
    }
    var selectedWorkout: Workout?
    var workoutManager: WorkoutManager?
    
    var state: State = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        if let styleURL = Bundle.main.url(forResource: "map_mirkwood", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        setupView(.none, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedMain" {
            if let vc = segue.destination as? MainViewController {
                vc.delegate = self
            }
        } else if segue.identifier == "embedSettings" {
            if let vc = segue.destination as? SettingsViewController {
                vc.delegate = self
            }
        } else if segue.identifier == "embedWorkout" {
            if let vc = segue.destination as? WorkoutViewController {
                vc.delegate = self
            }
        }
    }
    
    func updateView() {
        guard state == .none else { return }
        if isShowingMainView {
            mainViewOverlay.isUserInteractionEnabled = true
            actionView.isUserInteractionEnabled = false
        } else {
            mainViewOverlay.isUserInteractionEnabled = false
            actionView.isUserInteractionEnabled = true
        }
        actionView.alpha = percentShowingMainView
        //workoutStatsView.alpha = percentShowingMainView
        mainViewOverlay.alpha = 1 - percentShowingMainView
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
            mainViewContraint.constant = mainViewDefaultConstant
            workoutViewContraint.constant = workoutViewHiddenConstant
            actionView.alpha = 1
            workoutStatsView.alpha = 0
        case .live:
            mainViewContraint.constant = mainViewHiddenConstant
            workoutViewContraint.constant = workoutViewHiddenConstant
            actionView.alpha = 1
            workoutStatsView.alpha = 1
        case .past:
            mainViewContraint.constant = mainViewHiddenConstant
            workoutViewContraint.constant = workoutViewDefaultConstant
            workoutStatsView.alpha = 1
            actionView.alpha = 0
        }
        settingsViewContraint.constant = settingsViewHiddenConstant
    }
    
    func updateState(_ state: State) {
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
                self.updateState(state)
                self.updateView()
            }
        }
    }
    
}

extension ViewController {

    @IBAction func toggleWorkoutTapped(_ sender: Any) {
        if let workoutManager = workoutManager {
            workoutManager.toggle()
        } else {
            startWorkout()
        }
    }
    
    func startWorkout() {
        setupView(.live, animated: true)
        workoutManager = WorkoutManager(delegate: self)
    }
    
    @IBAction func endWorkoutTapped(_ sender: Any) {
        if let workout = workoutManager?.end() {
            let realm = try? Realm()
            try? realm?.write {
                realm?.add(workout)
            }
            showWorkout(workout)
        }
        workoutManager = nil
    }
    
    func showWorkout(_ workout: Workout) {
        setupView(.past, animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        workoutManager?.pause()
        UIView.animate(withDuration: 0.25, animations: {
            self.settingsViewContraint.constant = self.settingsViewFullConstant
            self.view.layoutIfNeeded()
        }) { (completed) in
            if completed {
            }
        }
    }
    
    @IBAction func centerMapTapped(_ sender: Any) {
        // TODO
    }
    
}

extension ViewController: WorkoutManagerDelegate {
    
    func workoutMangerDidChangeTime(_ workoutManager: WorkoutManager, timeElapsed: TimeInterval) {
        timeLabel.text = "\(Int(timeElapsed))"
    }

    func workoutMangerDidChangeDistance(_ workoutManager: WorkoutManager, distanceTraveled: CLLocationDistance) {
        distanceLabel.text = "\(Int(distanceTraveled))"
    }
    
    func workoutMangerDidStart(_ workoutManager: WorkoutManager, location: CLLocationCoordinate2D, speed: Double) {
        //
    }
    
    func workoutMangerDidAddSegment(_ workoutManager: WorkoutManager, location: CLLocationCoordinate2D, speed: Double) {
        //
    }
    
    func workoutMangerDidChangeState(_ workoutManager: WorkoutManager, state: WorkoutManager.WorkoutState) {
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

extension ViewController: MainViewControllerDelegate {
    
    var mainViewDefaultConstant: CGFloat {
        return view.bounds.height - 100
    }
    var mainViewHiddenConstant: CGFloat {
        return view.bounds.height
    }
    var mainViewFullConstant: CGFloat {
        return 0
    }
    var isShowingMainView: Bool {
        return mainViewContraint.constant == mainViewFullConstant
    }
    var percentShowingMainView: CGFloat {
        return mainViewContraint.constant/mainViewDefaultConstant
    }
    
    func mainViewPanned(_ panGesture: UIPanGestureRecognizer) {
        switch (panGesture.state) {
        case .began:
            break
        case .changed:
            var newConstant = mainViewContraint.constant + panGesture.translation(in: view).y
            newConstant = min(newConstant, mainViewDefaultConstant)
            newConstant = max(newConstant, mainViewFullConstant)
            mainViewContraint.constant = newConstant
            updateView()
            panGesture.setTranslation(.zero, in: view)
            break
        case .ended:
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                if (self.mainViewContraint.constant < (self.mainViewFullConstant + self.mainViewHiddenConstant)/2) {
                    self.mainViewContraint.constant = self.mainViewFullConstant
                } else {
                    self.mainViewContraint.constant = self.mainViewDefaultConstant
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
        selectedWorkout = nil
        setupView(.none, animated: true)
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
