//
//  SelectUpdateTimeTableViewController.swift
//  RedditStream
//
//  Created by Kurt Jensen on 3/15/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol SelectUpdateTimeTableViewControllerDelegate: class {
    func selectUpdateTimeTableViewControllerDidSelect(_ vc: SelectUpdateTimeTableViewController, updateTime: TimeInterval)
}

class SelectUpdateTimeTableViewController: UITableViewController {
    
    var selectedUpdateTime: TimeInterval = Settings.audioUpdateTime
    var updateTimes: [TimeInterval] = Settings.audioUpdateTimes
    weak var delegate: SelectUpdateTimeTableViewControllerDelegate?
    
    static let rowHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        tableView.rowHeight = SelectUpdateTimeTableViewController.rowHeight
        tableView.backgroundColor = Settings.theme.primaryTextColor
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateTimes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let time = updateTimes[indexPath.row]
        if time > 0 {
            cell.textLabel?.text = time.formatted(false)
        } else {
            cell.textLabel?.text = "Off"
        }
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let time = updateTimes[indexPath.row]
        if time == selectedUpdateTime {
            cell.textLabel?.textColor = Settings.theme.primaryTextColor
        } else {
            cell.textLabel?.textColor = Settings.theme.secondaryTextColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let time = updateTimes[indexPath.row]
        delegate?.selectUpdateTimeTableViewControllerDidSelect(self, updateTime: time)
    }
    
}

