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
}

class WorkoutViewController: UIViewController {
    
    static let storyboardId = "WorkoutViewController"
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    weak var delegate: WorkoutViewControllerDelegate?
    var workout: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.workoutViewControllerTappedClose(self)
        navigationController?.popViewController(animated: true)
    }
    
    func configure() {
        guard let workout = workout, !workout.isInvalidated else { return }
        titleLabel.text = workout.title
        subTitleLabel.text = workout.endDate?.timeAgo()
    }
    
}
