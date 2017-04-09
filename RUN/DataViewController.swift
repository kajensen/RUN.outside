//
//  DataViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/4/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import RealmSwift

class DataViewController: UIViewController {
    
    static let storyboardId = "DataViewController"

    var mapMyRunWorkoutIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func exportDataTapped(_ sender: Any) {
        showAlert(title: "TODO")
    }
    
    @IBAction func mapMyRunTapped(_ sender: Any) {
        showAlert(title: "Feature unavailable", message: "Please let us know that you want it!")
        //presentMapMyRun(self)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension DataViewController {
    
    func getMapMyRunWorkouts() {
        guard let user = MapMyRunUser.currentUser else { return }
        API.MapMyRun.getWorkouts(user, completion: { [weak self] (success, workoutIds) in
            self?.mapMyRunWorkoutIds = workoutIds
            self?.saveNextMapMyRunWorkout()
        })
    }
    
    func saveNextMapMyRunWorkout() {
        guard let user = MapMyRunUser.currentUser else { return }
        if let id = mapMyRunWorkoutIds.popLast() {
            mapMyRunWorkoutIds = [] // TODO
            API.MapMyRun.getWorkout(user, workoutId: id, completion: { [weak self] (success, workout) in
                print(success, workout)
            })
        }
    }
    
}

extension DataViewController: LoginDelegate {
    
    func didCompleteLogin(_ login: Login) {
        login.vc?.dismiss(animated: true, completion: nil)
    }
    
    func didGetSession(_ login: Login, session: Session?) {
        guard let session = session else {
            // TODO
            return
        }
        switch login.app {
        case .mapMyRun:
            API.MapMyRun.getUser(session, completion: { [weak self] (success, user) in
                if let user = user {
                    guard let realm = try? Realm() else { return }
                    try? realm.write {
                        realm.add(user, update: true)
                    }
                    self?.getMapMyRunWorkouts()
                }
            })
        }
    }
    
}
