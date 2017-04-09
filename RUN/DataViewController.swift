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

    @IBAction func exportDataTapped(_ sender: UIButton) {
        let alertController = RUNAlertController(title: "Export", message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = sender
        let csvAction = UIAlertAction(title: "CSV", style: .default) { (action) -> Void in
            let filename = "data.csv"
            guard let csvURL = self.exportToCSV(fileName: filename) else {
                return
            }
            self.export(sender, url: csvURL)
        }
        let jsonAction = UIAlertAction(title: "JSON", style: .default) { (action) -> Void in
            let filename = "data.json"
            guard let csvURL = self.exportToJSON(fileName: filename) else {
                return
            }
            self.export(sender, url: csvURL)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(csvAction)
        alertController.addAction(jsonAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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

extension DataViewController {
    
    func exportToCSV(fileName: String) -> URL? {
        guard let realm = try? Realm() else { return nil }
        guard let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first, let fileURL = NSURL(fileURLWithPath: docPath).appendingPathComponent(fileName) else {
            return nil
        }
        var csv = ""
        let workouts = realm.objects(Workout.self).sorted(byKeyPath: "startDate", ascending: false)
        for workout in workouts {
            csv += workout.toCSV()
        }
        try? csv.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        return fileURL
    }
    
    func exportToJSON(fileName: String) -> URL? {
        guard let realm = try? Realm() else { return nil }
        guard let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first, let fileURL = NSURL(fileURLWithPath: docPath).appendingPathComponent(fileName) else {
            return nil
        }
        var workoutsJSON: [[String: Any?]] = []
        let workouts = realm.objects(Workout.self).sorted(byKeyPath: "startDate", ascending: false)
        for workout in workouts {
            let json = workout.toJSON()
            workoutsJSON.append(json)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["workouts": workoutsJSON], options: .prettyPrinted)
            try jsonData.write(to: fileURL, options: Data.WritingOptions.atomic)
            return fileURL
        } catch {
            print(error)
            return nil
        }
    }
    
    func export(_ sender: UIButton, url: URL) {
        let activityViewController = RUNActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender
        present(activityViewController, animated: true, completion: nil)
    }
    
}
