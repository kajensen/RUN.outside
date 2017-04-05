//
//  MainViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import CoreLocation

protocol WorkoutsViewControllerDelegate: class {
    func workoutsViewControllerDidClose(_ vc: WorkoutsViewController, workout: Workout?)
    func workoutsViewControllerDidSelect(_ vc: WorkoutsViewController, workout: Workout)
}

class WorkoutsViewController: UIViewController {
    
    static let yearDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter
    }()
    
    static let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter
    }()
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var workoutsInfoLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dataView: DataView!
    @IBOutlet weak var workoutDataSpanButtonStackView: UIStackView!
    
    var workoutDataSpanButtons: [WorkoutDataSpanButton] {
        return workoutDataSpanButtonStackView.arrangedSubviews as! [WorkoutDataSpanButton]
    }
    
    fileprivate (set) var workoutsNotificationToken: NotificationToken? = nil
    internal var workouts: Results<Workout>?
    
    internal var dayWorkouts: [Date: [Workout]] = [:]
    internal var days: [Date] = []
    var barDataSets: [BarChartDataSet]?
    var lineDataSet: LineChartDataSet?
    
    var lineWorkoutData: WorkoutData = .speed
    var barWorkoutData: WorkoutData = .distance
    
    weak var delegate: WorkoutsViewControllerDelegate?
    
    var workoutDataSpan: WorkoutDataSpan = .week
    
    var dateFormatter: DateFormatter {
        switch workoutDataSpan {
        case .year:
            return WorkoutsViewController.yearDateFormatter
        default:
            return WorkoutsViewController.defaultDateFormatter
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = WorkoutTableViewCell.rowHeight
        tableView.register(UINib(nibName: WorkoutTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: WorkoutTableViewCell.nibName)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0)
        distanceLabel.text = nil
        workoutsInfoLabel.text = nil
        dataView.dataSource = self
        setupWorkoutsNotification()
        registerForThemeChange()
    }
    
    override func configureTheme() {
        tableView.separatorColor = UIColor.clear
        let theme = Settings.theme
        titleLabel.textColor = theme.primaryTextColor
        subTitleLabel.textColor = theme.secondaryTextColor
        distanceLabel.textColor = theme.primaryTextColor
        workoutsInfoLabel.textColor = theme.secondaryTextColor
        if let bgView = view as? BGView {
            bgView.effect = theme.blurEffect
        }
        tableView.reloadData()
        //
        for button in workoutDataSpanButtons {
            button.isSelected = button.workoutDataSpan == workoutDataSpan
        }
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
                self?.configure()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.endUpdates()
                self?.configure()
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
    
    @IBAction func dataSpanTapped(_ sender: WorkoutDataSpanButton) {
        for button in workoutDataSpanButtons {
            button.isSelected = sender == button
        }
        workoutDataSpan = sender.workoutDataSpan
        reloadData()
    }
    
}

extension WorkoutsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = workouts else { return 0 }
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.nibName, for: indexPath) as! WorkoutTableViewCell
        let workout = workouts![indexPath.row]
        cell.configure(with: workout)
        cell.aDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let workout = workouts![indexPath.row]
        show(workout)
    }
    
    func show(_ workout: Workout) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: WorkoutViewController.storyboardId) as? WorkoutViewController else { return }
        vc.workout = workout
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: false)
        delegate?.workoutsViewControllerDidSelect(self, workout: workout)
    }
    
}

extension WorkoutsViewController: WorkoutTableViewCellDelegate {
    
    func workoutTableViewCellTappedDelete(_ cell: WorkoutTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let workout = self.workouts?[indexPath.row] else { return }
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.delete(workout)
        }
    }
    
}

extension WorkoutsViewController: WorkoutViewControllerDelegate {
    
    func workoutViewControllerTappedClose(_ vc: WorkoutViewController) {
        delegate?.workoutsViewControllerDidClose(self, workout: nil)
    }
    
}

extension WorkoutsViewController: DataViewDataSource {
    
    func configure() {
        var totalDistance: CLLocationDistance = 0
        if let workouts = workouts {
            for workout in workouts {
                totalDistance += workout.totalDistance
            }
        }
        distanceLabel.text = Utils.distanceString(meters: totalDistance)
        let totalNumWorkouts = workouts?.count ?? 0
        workoutsInfoLabel.text = "\(totalNumWorkouts) run\(totalNumWorkouts == 1 ? "" : "s") this \(workoutDataSpan.title)"
        reloadData()
    }
    
    func reloadData() {
        days.removeAll()
        dayWorkouts.removeAll()
        loadData()
        dataView.reloadData()
    }
    
    func loadData() {
        guard let workouts = workouts else { return }
        for date in workoutDataSpan.dates {
            dayWorkouts[date] = []
            days.append(date)
        }
        for workout in workouts {
            if let date = workout.startDate?.dateWithoutTime() {
                if var workouts = dayWorkouts[date] {
                    workouts.append(workout)
                    dayWorkouts[date] = workouts
                }
            }
        }
        var barEntries: [BarChartDataEntry] = []
        var lineEntries: [ChartDataEntry] = []
        var index = 0
        for (_, workouts) in dayWorkouts {
            var barSum: Double = 0
            var lineSum: Double = 0
            for workout in workouts {
                switch lineWorkoutData {
                case .speed:
                    lineSum += workout.totalDistance/workout.totalTimeActive
                case .distance:
                    lineSum += workout.totalDistance
                case .elevation:
                    lineSum += workout.totalPositiveAltitude
                default:
                    break
                }
                switch barWorkoutData {
                case .speed:
                    barSum += workout.totalDistance/workout.totalTimeActive
                case .distance:
                    barSum += workout.totalDistance
                case .elevation:
                    barSum += workout.totalPositiveAltitude
                default:
                    break
                }
            }
            let barAvg = barSum/Double(workouts.count)
            let lineAvg = lineSum/Double(workouts.count)
            barEntries.append(BarChartDataEntry(x: Double(index), y: barAvg.isNaN ? 0 : barAvg))
            lineEntries.append(ChartDataEntry(x: Double(index), y: lineAvg.isNaN ? 0 : lineAvg))
            index += 1
        }
        let barDataSet = BarChartDataSet(values: barEntries, label: barWorkoutData.title)
        barDataSet.colors = [Settings.theme.alternateTextColor]
        barDataSet.axisDependency = .left
        let lineDataSet = LineChartDataSet(values: lineEntries, label: lineWorkoutData.title)
        lineDataSet.axisDependency = .right
        lineDataSet.colors = [Settings.theme.primaryTextColor]
        self.lineDataSet = lineDataSet
        self.barDataSets = [barDataSet]
    }
    
}

extension WorkoutsViewController {
    
    func xAxis(value: Double) -> String? {
        guard let day = days[safe: Int(value)] else {
            return nil
        }
        return dateFormatter.string(from: day)
    }
    
    func yAxis(value: Double, isLeft: Bool) -> String? {
        let data = isLeft ? barWorkoutData : lineWorkoutData
        switch data {
        case .speed:
            return Utils.distanceRateString(unitsPerHour: Utils.unitsPerHour(metersPerSecond: value))
        case .distance:
            return Utils.distanceString(meters: value)
        case .heartbeat:
            return "\(Int(value)) bmp"
        case .elevation:
            return Utils.distanceString(meters: value)
        }
    }
    
}
