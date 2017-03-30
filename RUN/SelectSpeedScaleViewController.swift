//
//  SelectSpeedScaleViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/30/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol SelectSpeedScaleViewControllerDelegate: class {
    func selectSpeedScaleViewControllerDidSelect(_ vc: SelectSpeedScaleViewController, speedRateSlow: Double, speedRateMedium: Double, speedRateFast: Double)
}

class SelectSpeedScaleViewController: UIViewController {
    
    weak var delegate: SelectSpeedScaleViewControllerDelegate?
    
    lazy var speedPicker: UIPickerView = {
        let speedPicker = UIPickerView(frame: self.view.bounds)
        speedPicker.dataSource = self
        speedPicker.delegate = self
        return speedPicker
    }()
    
    let speedRates: [Double] = Settings.speedRates
    
    var speedRateSlow: Double {
        return speedRates[speedPicker.selectedRow(inComponent: 0)]
    }
    var speedRateMedium: Double {
        return speedRates[speedPicker.selectedRow(inComponent: 1)+1]
    }
    var speedRateFast: Double {
        return speedRates[speedPicker.selectedRow(inComponent: 2)+2]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackViewHeader()
        setupSpeedPicker()
    }

    func setupStackViewHeader() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        for header in [("Slow", Settings.theme.orangeColor), ("Medium", Settings.theme.yellowColor), ("Fast", Settings.theme.greenColor)] {
            let label = UILabel()
            label.text = header.0
            label.textColor = header.1
            label.font = Style.Font.bold(of: 14)
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
    }
    
    func setupSpeedPicker() {
        speedPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(speedPicker)
        speedPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speedPicker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        speedPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speedPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let speedRateSlowIndex = speedRates.index(of: Settings.speedRateSlow) ?? 0
        let speedRateMediumIndex: Int
        if let speedRate = speedRates.index(of: Settings.speedRateMedium), speedRate > 0 {
            speedRateMediumIndex = speedRate - 1
        } else {
            speedRateMediumIndex = speedRateSlowIndex
        }
        let speedRateFastIndex: Int
        if let speedRate = speedRates.index(of: Settings.speedRateFast), speedRate > 1 {
            speedRateFastIndex = speedRate - 2
        } else {
            speedRateFastIndex = speedRateMediumIndex
        }
        speedPicker.selectRow(speedRateSlowIndex, inComponent: 0, animated: false)
        speedPicker.selectRow(speedRateMediumIndex, inComponent: 1, animated: false)
        speedPicker.selectRow(speedRateFastIndex, inComponent: 2, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.selectSpeedScaleViewControllerDidSelect(self, speedRateSlow: speedRateSlow, speedRateMedium: speedRateMedium, speedRateFast: speedRateFast)
    }

}

extension SelectSpeedScaleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.bounds.width/CGFloat(self.numberOfComponents(in: pickerView))
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return speedRates.count - 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var realIndex: Int
        switch component {
        case 0:
            realIndex = row
        case 1:
            realIndex = row + 1
        default:
            realIndex = row + 2
        }
        let rate = speedRates[realIndex]
        return "\(Utils.distanceRateString(unitsPerHour: rate))"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel = (view as? UILabel) ?? UILabel()
        label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        label.font = Style.Font.regular(of: 14)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var slowIndex = pickerView.selectedRow(inComponent: 0)
        var mediumIndex = pickerView.selectedRow(inComponent: 1)
        var fastIndex = pickerView.selectedRow(inComponent: 2)
        switch component {
        case 0:
            mediumIndex = max(mediumIndex, slowIndex)
            fastIndex = max(fastIndex, slowIndex)
        case 1:
            slowIndex = min(slowIndex, mediumIndex)
            fastIndex = max(fastIndex, mediumIndex)
        case 2:
            slowIndex = min(slowIndex, fastIndex)
            mediumIndex = min(mediumIndex, fastIndex)
        default:
            break
        }

        if slowIndex != pickerView.selectedRow(inComponent: 0) {
            pickerView.selectRow(slowIndex, inComponent: 0, animated: true)
        }
        if mediumIndex != pickerView.selectedRow(inComponent: 1) {
            pickerView.selectRow(mediumIndex, inComponent: 1, animated: true)
        }
        if fastIndex != pickerView.selectedRow(inComponent: 2) {
            pickerView.selectRow(fastIndex, inComponent: 2, animated: true)
        }
    }
    
}
