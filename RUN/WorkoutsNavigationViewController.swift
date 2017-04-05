//
//  WorkoutsNavigationViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/4/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class WorkoutsNavigationViewController: UINavigationController {

    var tableView: UITableView? {
        let vc = childViewControllers.last
        if let vc = vc as? WorkoutsViewController {
            return vc.tableView
        } else if let vc = vc as? WorkoutViewController {
            return vc.tableView
        }
        return nil
    }
    
}
