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
    
    private (set) var intervals: [TimeInterval: [WorkoutEvent]] = [:]
    var barDataSets: [BarChartDataSet]?
    var lineDataSet: LineChartDataSet?
    
    var lineWorkoutData: WorkoutData = .speed
    var barWorkoutData: WorkoutData = .elevation
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var dataView: DataView!
    
    var interval: TimeInterval = 15
    
    weak var delegate: WorkoutViewControllerDelegate?
    var workout: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataView.dataSource = self
        configure()
        registerForThemeChange()
    }
    
    override func configureTheme() {
        let theme = Settings.theme
        titleLabel.textColor = theme.primaryTextColor
        subTitleLabel.textColor = theme.secondaryTextColor
        if let bgView = view as? BGView {
            bgView.effect = theme.blurEffect
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.workoutViewControllerTappedClose(self)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func barDataTapped(_ sender: WorkoutDataButton) {
        barWorkoutData = sender.workoutData
        reloadData()
    }
    
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
        if isLeft {
            return Utils.distanceString(meters: value)
        } else {
            return Utils.distanceRateString(unitsPerHour: Utils.unitsPerHour(metersPerSecond: value))
        }
    }
    
}
