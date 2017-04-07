//
//  SplashViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/30/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import CoreLocation

class SplashViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Settings.hasOnboarded {
            toOnboarding()
        } else if CLLocationManager.authorizationStatus() != .authorizedAlways {
            promptLocation()
        } else {
            toMain()
        }
    }
    
    func toOnboarding() {
        guard let vc = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() else { return }
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func toMain() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: MapViewController.storyboardId) else { return }
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func promptLocation() {
        showAlert(title: "Location Permissions", message: "You haven't granted (or disabled) RUN to use your location. Please go to the settings app and allow location use.")
    }
    
}
