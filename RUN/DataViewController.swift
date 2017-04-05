//
//  DataViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/4/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    
    static let storyboardId = "DataViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
