//
//  DataView.swift
//  RUN
//
//  Created by Kurt Jensen on 3/31/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import Charts

protocol DataViewDataSource: class {
    var lineDataSet: LineChartDataSet? { get set }
    var barDataSets: [BarChartDataSet]? { get set }
    func xAxis(value: Double) -> String?
    func yAxis(value: Double, isLeft: Bool) -> String?
}

class DataView: CombinedChartView {
    
    weak var dataSource: DataViewDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    internal func commonInit() {
        delegate = self
        xAxis.valueFormatter = self
        leftAxis.valueFormatter = self
        //
        backgroundColor = UIColor.white.withAlphaComponent(0.01)
        gridBackgroundColor = UIColor.clear
        noDataText = "No data (yet)"
        chartDescription?.text = ""
        rightAxis.drawGridLinesEnabled = false
        leftAxis.drawGridLinesEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        leftAxis.axisMinimum = 0
        rightAxis.axisMinimum = 0
        xAxis.centerAxisLabelsEnabled = true
        rightAxis.enabled = true
        legend.enabled = true
        //fitBars = true
        highlightPerDragEnabled = false
        highlightPerTapEnabled = false
        configureTheme()
    }
    
    func configureTheme() {
        let theme = Settings.theme
        xAxis.labelTextColor = theme.primaryTextColor
        xAxis.gridColor = theme.secondaryTextColor
        xAxis.axisLineColor = theme.secondaryTextColor
        leftAxis.labelTextColor = theme.primaryTextColor
        leftAxis.gridColor = theme.secondaryTextColor
        leftAxis.axisLineColor = theme.secondaryTextColor
        legend.textColor = theme.primaryTextColor
    }
    
    func reloadData() {
        guard let barChartDataSets = self.dataSource?.barDataSets else {
            return
        }
        guard let lineChartDataSet = self.dataSource?.lineDataSet else {
            return
        }
        lineChartDataSet.circleHoleColor = lineChartDataSet.colors.first
        lineChartDataSet.circleColors = lineChartDataSet.colors
        lineChartDataSet.circleRadius = 2
        lineChartDataSet.lineWidth = 2
        let lineData = LineChartData(dataSet: lineChartDataSet)
        let barData = BarChartData(dataSets: barChartDataSets)
        if barChartDataSets.count > 1 {
            let groupSpace: Double = 0
            let barWidth = 1/Double(barChartDataSets.count+1)
            let barSpace = barWidth/Double(barChartDataSets.count)
            barData.barWidth = barWidth
            barData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        }
        let data: CombinedChartData = CombinedChartData()
        data.lineData = lineData
        data.barData = barData
        data.setValueFormatter(self)
        data.setValueTextColor(Settings.theme.primaryTextColor)
        self.data = data
        self.animate(yAxisDuration: 3, easingOption: .easeInOutExpo)
    }
    
}

extension DataView: ChartViewDelegate, IAxisValueFormatter, IValueFormatter {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("\(entry) in \(entry.index)")
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if axis == xAxis {
            return dataSource?.xAxis(value: value) ?? ""
        }
        return dataSource?.yAxis(value: value, isLeft: axis == leftAxis) ?? ""
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard value > 0 else {
            return ""
        }
        return ""//dataSource?.yAxis(value: value, index: dataSetIndex) ?? ""
    }
    
}
