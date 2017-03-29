//
//  WorkoutTableViewCell.swift
//  RUN
//
//  Created by Kurt Jensen on 3/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    static let rowHeight: CGFloat = 60
    static let nibName = "WorkoutTableViewCell"
    
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        routeImageView.image = nil
        dateLabel.text = nil
        timeElapsedLabel.text = nil
        distanceLabel.text = nil
        elevationLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with workout: Workout) {
        dateLabel.text = workout.title
        timeElapsedLabel.text = TimeInterval(workout.totalTimeActive).formatted()
        distanceLabel.text = Utils.distanceString(meters: workout.totalDistance)
        elevationLabel.text = "\(Utils.distanceString(meters: workout.totalPositiveElevation)) (+\(Utils.distanceString(meters: workout.netElevation)))"
        routeImageView.image = workout.pathImageForSize(rect: routeImageView.bounds)
    }
    
}
