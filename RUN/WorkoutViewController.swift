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
    
    var barDataSets: [BarChartDataSet]?
    var lineDataSet: LineChartDataSet?
    
    var lineWorkoutData: WorkoutData = .speed
    var barWorkoutData: WorkoutData = .elevation
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var shareBGView: BGView!
    @IBOutlet weak var closeBGView: BGView!
    @IBOutlet weak var dataView: DataView!
    @IBOutlet weak var workoutDataButtonStackView: UIStackView!
    
    var workoutDataButtons: [WorkoutDataButton] {
        return workoutDataButtonStackView.arrangedSubviews as! [WorkoutDataButton]
    }
    
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
        shareBGView.effect = theme.blurEffect
        closeBGView.effect = theme.blurEffect
        //
        for button in workoutDataButtons {
            button.isSelected = button.workoutData == barWorkoutData
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.workoutViewControllerTappedClose(self)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        guard let image = view.snapshot() else { return }
        let activityViewController = RUNActivityViewController(activityItems: ["Check out my workout I just completed with RUN", image, Constants.appStoreURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender
        present(activityViewController, animated: true, completion: nil)
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
        loadData(workout)
        dataView.reloadData()
    }

    func loadData(_ workout: Workout) {
        guard let startDate = workout.startDate else { return }
        var barEntries: [BarChartDataEntry] = []
        var lineEntries: [ChartDataEntry] = []
        var previousEvent: WorkoutEvent?
        
        var intervals: [Int: WorkoutDataInterval] = [:]
        let interval = 15
        for lap in workout.laps {
            for event in lap.events {
                let index = (Int(event.timestamp.timeIntervalSince(startDate))/interval)*interval
                let lineValue = lineWorkoutData.value(event, previousEvent: previousEvent)
                let barValue = barWorkoutData.value(event, previousEvent: previousEvent)
                var interval = intervals[index] ?? WorkoutDataInterval()
                interval.barValues.append(barValue)
                interval.lineValues.append(lineValue)
                intervals[index] = interval
                previousEvent = event
            }
        }
        
        for index in intervals.keys.sorted() {
            if let interval = intervals[index] {
                let barValue = barWorkoutData.value(values: interval.barValues)
                barEntries.append(BarChartDataEntry(x: Double(index), y: barValue))
                lineEntries.append(ChartDataEntry(x: Double(index), y: interval.lineValue))
            }
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

struct WorkoutDataInterval {
    var barValues: [Double] = []
    var lineValues: [Double] = []
    var barValue: Double {
        guard barValues.count > 0 else {
            return 0
        }
        var barValue: Double = 0
        for value in barValues {
            barValue += value
        }
        return barValue/Double(barValues.count)
    }
    var lineValue: Double {
        guard lineValues.count > 0 else {
            return 0
        }
        var lineValue: Double = 0
        for value in lineValues {
            lineValue += value
        }
        return lineValue/Double(lineValues.count)
    }
}

extension WorkoutViewController {
    
    func xAxis(value: Double) -> String? {
        return TimeInterval(value).formatted(false)
    }
    
    func yAxis(value: Double, isLeft: Bool) -> String? {
        let data = isLeft ? barWorkoutData : lineWorkoutData
        return data.string(value: value)
    }
    
}
