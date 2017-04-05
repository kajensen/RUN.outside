//
//  WorkoutViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/25/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

protocol WorkoutViewControllerDelegate: class {
    func workoutViewControllerTappedClose(_ vc: WorkoutViewController)
}

class WorkoutViewController: UIViewController, DataViewDataSource {
    
    static let storyboardId = "WorkoutViewController"
    
    internal var intervals: [TimeInterval: [WorkoutEvent]] = [:]
    var barDataSets: [BarChartDataSet]?
    var lineDataSet: LineChartDataSet?
    
    var lineWorkoutData: WorkoutData = .speed
    var barWorkoutData: WorkoutData = .distance
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var dataView: DataView!
    @IBOutlet weak var workoutDataButtonStackView: UIStackView!
    
    var workoutDataButtons: [WorkoutDataButton] {
        return workoutDataButtonStackView.arrangedSubviews as! [WorkoutDataButton]
    }
    
    var interval: TimeInterval = 15
    
    weak var delegate: WorkoutViewControllerDelegate?
    var workout: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = WorkoutLapTableViewCell.rowHeight
        tableView.register(UINib(nibName: WorkoutLapTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: WorkoutLapTableViewCell.nibName)
        tableView.dataSource = self
        dataView.dataSource = self
        configure()
        registerForThemeChange()
        tableView.reloadData()
    }
    
    override func configureTheme() {
        let theme = Settings.theme
        titleLabel.textColor = theme.primaryTextColor
        subTitleLabel.textColor = theme.secondaryTextColor
        if let bgView = view as? BGView {
            bgView.effect = theme.blurEffect
        }
        //
        for button in workoutDataButtons {
            button.isSelected = button.workoutData == barWorkoutData
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.workoutViewControllerTappedClose(self)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        showAlert(title: "TODO")
    }
    
    @IBAction func barDataTapped(_ sender: WorkoutDataButton) {
        for button in workoutDataButtons {
            button.isSelected = sender == button
        }
        barWorkoutData = sender.workoutData
        reloadData()
    }
    
}

extension WorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let laps = workout?.laps else { return 0 }
        return laps.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutLapTableViewCell.nibName, for: indexPath) as! WorkoutLapTableViewCell
        let lap = workout!.laps[indexPath.row]
        cell.configure(with: lap, row: indexPath.row+1)
        return cell
    }

}

extension WorkoutViewController {

    func configure() {
        guard let workout = workout, !workout.isInvalidated else { return }
        titleLabel.text = workout.title
        subTitleLabel.text = workout.endDate?.timeAgo()
        reloadData()
    }
    
    func reloadData() {
        guard let workout = workout, !workout.isInvalidated else { return }
        intervals.removeAll()
        loadData(workout)
        dataView.reloadData()
    }

    func loadData(_ workout: Workout) {
        var interval = nearest15Seconds(i: workout.startDate!.timeIntervalSince1970)
        let endInterval = nearest15Seconds(i: workout.endDate!.timeIntervalSince1970)
        while interval <= endInterval {
            intervals[interval] = []
            interval += 15
        }
        for lap in workout.laps {
            for event in lap.events {
                if event.workoutEventType == .locationUpdate {
                    let interval = nearest15Seconds(i: event.timestamp.timeIntervalSince1970)
                    if var events = intervals[interval] {
                        events.append(event)
                        intervals[interval] = events
                    }
                }
            }
        }
        var barEntries: [BarChartDataEntry] = []
        var lineEntries: [ChartDataEntry] = []
        var index = 0
        for (_, events) in intervals {
            var barSum: Double = 0
            var lineSum: Double = 0
            for event in events {
                switch lineWorkoutData {
                case .speed:
                    lineSum += event.speed
                case .distance:
                    lineSum += event.distanceTraveled
                case .heartbeat:
                    lineSum += event.heartRate
                case .elevation:
                    lineSum += event.altitude
                }
                switch barWorkoutData {
                case .speed:
                    barSum += event.speed
                case .distance:
                    barSum += event.distanceTraveled
                case .heartbeat:
                    barSum += event.heartRate
                case .elevation:
                    barSum += event.altitude
                }
            }
            let barAvg = barSum/Double(events.count)
            let lineAvg = lineSum/Double(events.count)
            barEntries.append(BarChartDataEntry(x: Double(index), y: barAvg))
            lineEntries.append(ChartDataEntry(x: Double(index), y: lineAvg))
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
 
    func nearest15Seconds(i: TimeInterval) -> TimeInterval {
        return interval * TimeInterval(Darwin.round(i / interval))
    }
    
}

extension WorkoutViewController {
    
    func xAxis(value: Double) -> String? {
        return TimeInterval(value*15).formatted(false)
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
