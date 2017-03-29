//
//  MainViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import RealmSwift

protocol WorkoutsViewControllerDelegate: class {
    func workoutsViewControllerDidSelect(_ vc: WorkoutsViewController, workout: Workout)
    func workoutsViewPanned(_ panGesture: UIPanGestureRecognizer)
}

class WorkoutsViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate (set) var workoutsNotificationToken: NotificationToken? = nil
    internal var workouts: Results<Workout>?
    
    weak var delegate: WorkoutsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = WorkoutTableViewCell.rowHeight
        tableView.register(UINib(nibName: WorkoutTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: WorkoutTableViewCell.nibName)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WorkoutsViewController.viewPanned(_:)))
        topView.addGestureRecognizer(panGestureRecognizer)
        setupWorkoutsNotification()
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
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.endUpdates()
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
