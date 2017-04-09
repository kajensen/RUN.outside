//
//  AboutViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/9/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    static let storyboardId = "AboutViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
