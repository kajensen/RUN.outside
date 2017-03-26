//
//  SettingsViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/25/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerTappedClose(_ vc: SettingsViewController)
    func settingsViewPanned(_ panGesture: UIPanGestureRecognizer)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SettingsViewController.viewPanned(_:)))
        bottomView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func viewPanned(_ panGesture: UIPanGestureRecognizer) {
        delegate?.settingsViewPanned(panGesture)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.settingsViewControllerTappedClose(self)
    }

}
