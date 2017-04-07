//
//  SelectLapDistanceTableViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/30/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol SelectLapDistanceTableViewControllerDelegate: class {
    func selectLapDistanceTableViewControllerDidSelect(_ vc: SelectLapDistanceTableViewController, lapDistance: Double)
}

class SelectLapDistanceTableViewController: UITableViewController {
    
    var selectedDistance: Double = Settings.lapDistance
    var lapDistances: [Double] = Settings.lapDistances
    weak var delegate: SelectLapDistanceTableViewControllerDelegate?
    
    static let rowHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        tableView.rowHeight = SelectUpdateTimeTableViewController.rowHeight
        //tableView.backgroundColor = Settings.theme.primaryTextColor
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapDistances.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let distance = lapDistances[indexPath.row]
        if distance > 0 {
            cell.textLabel?.text = Utils.longDistanceString(meters: distance)
        } else {
            cell.textLabel?.text = "Off"
        }
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let distance = lapDistances[indexPath.row]
        if distance == selectedDistance {
            cell.textLabel?.textColor = Settings.theme.primaryTextColor
        } else {
            cell.textLabel?.textColor = Settings.theme.secondaryTextColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let distance = lapDistances[indexPath.row]
        delegate?.selectLapDistanceTableViewControllerDidSelect(self, lapDistance: distance)
    }
    
}
