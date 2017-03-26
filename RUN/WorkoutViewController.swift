//
//  WorkoutViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/25/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol WorkoutViewControllerDelegate: class {
    func workoutViewControllerTappedClose(_ vc: WorkoutViewController)
    func workoutViewPanned(_ panGesture: UIPanGestureRecognizer)
}

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    
    weak var delegate: WorkoutViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WorkoutViewController.viewPanned(_:)))
        topView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func viewPanned(_ panGesture: UIPanGestureRecognizer) {
        delegate?.workoutViewPanned(panGesture)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.workoutViewControllerTappedClose(self)
    }
    
}
