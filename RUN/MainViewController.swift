//
//  MainViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/24/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate: class {
    func mainViewPanned(_ panGesture: UIPanGestureRecognizer)
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    
    weak var delegate: MainViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.viewPanned(_:)))
        topView.addGestureRecognizer(panGestureRecognizer)
    }

    func viewPanned(_ panGesture: UIPanGestureRecognizer) {
        delegate?.mainViewPanned(panGesture)
    }
    
}
