//
//  WorkoutTableViewCell.swift
//  RUN
//
//  Created by Kurt Jensen on 3/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol WorkoutTableViewCellDelegate: class {
    func workoutTableViewCellTappedDelete(_ cell: WorkoutTableViewCell)
}

class WorkoutTableViewCell: MGSwipeTableCell {
    
    static let rowHeight: CGFloat = 72
    static let nibName = "WorkoutTableViewCell"
    
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    
    weak var aDelegate: WorkoutTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let rightButton = MGSwipeButton(title: "Delete", icon: UIImage(named: "trash"), backgroundColor: UIColor.red, padding: 32) { (cell) -> Bool in
            guard let cell = cell as? WorkoutTableViewCell else { return false }
            cell.aDelegate?.workoutTableViewCellTappedDelete(cell)
            return true
        }
        rightButton.tintColor = UIColor.white
        rightButtons = [rightButton]
        prepareForReuse()
        routeImageView.transform = CGAffineTransform.identity.scaledBy(x: -1, y: 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        routeImageView.image = nil
        dateLabel.text = nil
        timeElapsedLabel.text = nil
        distanceLabel.text = nil
        elevationLabel.text = nil
        let theme = Settings.theme
        routeImageView.tintColor = theme.primaryTextColor
        dateLabel.textColor = theme.primaryTextColor
        timeElapsedLabel.textColor = theme.secondaryTextColor
        distanceLabel.textColor = theme.primaryTextColor
        elevationLabel.textColor = theme.secondaryTextColor
        rightButtons.first?.backgroundColor = theme.redColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with workout: Workout) {
        dateLabel.text = workout.title
        timeElapsedLabel.text = TimeInterval(workout.totalTimeActive).formatted()
        distanceLabel.text = Utils.distanceString(meters: workout.totalDistance)
        elevationLabel.text = "\(Utils.distanceString(meters: workout.netAltitude)) (+\(Utils.distanceString(meters: workout.totalPositiveAltitude)))"
        routeImageView.image = workout.routeImage(rect: routeImageView.bounds)?.withRenderingMode(.alwaysTemplate)
    }
    
}
