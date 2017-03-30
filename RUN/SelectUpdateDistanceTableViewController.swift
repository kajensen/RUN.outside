//
//  SelectUpdateDistanceTableViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/29/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol SelectUpdateDistanceTableViewControllerDelegate: class {
    func selectUpdateDistanceTableViewControllerDidSelect(_ vc: SelectUpdateDistanceTableViewController, updateDistance: Double)
}

class SelectUpdateDistanceTableViewController: UITableViewController {
    
    var selectedDistance: Double = Settings.audioUpdateDistance
    var updateDistances: [Double] = Settings.audioUpdateDistances
    weak var delegate: SelectUpdateDistanceTableViewControllerDelegate?
    
    static let rowHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        tableView.rowHeight = SelectUpdateTimeTableViewController.rowHeight
        //tableView.backgroundColor = Settings.theme.primaryTextColor
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateDistances.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let distance = updateDistances[indexPath.row]
        if distance > 0 {
            cell.textLabel?.text = distance.formatted(false)
        } else {
            cell.textLabel?.text = "Off"
        }
        cell.textLabel?.text = Utils.distanceString(meters: distance)
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let distance = updateDistances[indexPath.row]
        if distance == selectedDistance {
            cell.textLabel?.textColor = Settings.theme.primaryTextColor
        } else {
            cell.textLabel?.textColor = Settings.theme.secondaryTextColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let distance = updateDistances[indexPath.row]
        delegate?.selectUpdateDistanceTableViewControllerDidSelect(self, updateDistance: distance)
    }
    
}
