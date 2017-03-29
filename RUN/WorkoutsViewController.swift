//
//  MainViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

protocol WorkoutsViewControllerDelegate: class {
    func workoutsViewControllerDidSelect(_ vc: WorkoutsViewController, workout: Workout)
    func workoutsViewPanned(_ panGesture: UIPanGestureRecognizer)
}

class WorkoutsViewController: UIViewController {
    
    enum TimeSpan {
        case week, month, year
        var title: String {
            switch self {
            case .week:
                return "week"
            case .month:
                return "month"
            case .year:
                return "year"
            }
        }
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var workoutsInfoLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherInfoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate (set) var workoutsNotificationToken: NotificationToken? = nil
    internal var workouts: Results<Workout>?
    
    weak var delegate: WorkoutsViewControllerDelegate?
    
    var timeSpan: TimeSpan = .week
    var lastWeatherUpdate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = WorkoutTableViewCell.rowHeight
        tableView.register(UINib(nibName: WorkoutTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: WorkoutTableViewCell.nibName)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WorkoutsViewController.viewPanned(_:)))
        topView.addGestureRecognizer(panGestureRecognizer)
        temperatureLabel.text = nil
        weatherInfoLabel.text = nil
        distanceLabel.text = nil
        workoutsInfoLabel.text = nil
        setupWorkoutsNotification()
    }
    
    func updateWeatherIfNeeded(coordinate: CLLocationCoordinate2D) {
        if let lastWeatherUpdate = lastWeatherUpdate, lastWeatherUpdate.timeIntervalSinceNow < 60*10 {
            return
        }
        lastWeatherUpdate = Date()
        updateWeather(coordinate: coordinate)
    }
        
    func updateWeather(coordinate: CLLocationCoordinate2D) {
        API.getCurrentWeather(coordinate.latitude, lng: coordinate.longitude) { [weak self] (success, weather) in
            if success, let weather = weather {
                self?.temperatureLabel.text = Utils.tempuratureString(kelvin: weather.temperatureInKelvin)
                self?.weatherInfoLabel.text = weather.description
            }
        }
    }
    
    func didUpdateWorkouts() {
        var totalDistance: CLLocationDistance = 0
        if let workouts = workouts {
            for workout in workouts {
                totalDistance += workout.totalDistance
            }
        }
        distanceLabel.text = Utils.distanceString(meters: totalDistance)
        workoutsInfoLabel.text = "\(workouts?.count ?? 0) runs this \(timeSpan.title)"
    }

    func viewPanned(_ panGesture: UIPanGestureRecognizer) {
        delegate?.workoutsViewPanned(panGesture)
    }
    
    func setupWorkoutsNotification() {
        workoutsNotificationToken?.stop()
        guard let realm = try? Realm() else { return }
        workouts = realm.objects(Workout.self).sorted(byKeyPath: "startDate", ascending: false)
        workoutsNotificationToken = workouts?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
                self?.didUpdateWorkouts()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.endUpdates()
                self?.didUpdateWorkouts()
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }
    
    deinit {
        workoutsNotificationToken?.stop()
    }
    
}

extension WorkoutsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = workouts else { return 0 }
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.nibName, for: indexPath) as! WorkoutTableViewCell
        let workout = workouts![indexPath.row]
        cell.configure(with: workout)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let workout = workouts![indexPath.row]
        delegate?.workoutsViewControllerDidSelect(self, workout: workout)
    }
    
}
