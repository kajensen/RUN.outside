//
//  WorkoutLapTableViewCell.swift
//  RUN
//
//  Created by Kurt Jensen on 4/4/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class WorkoutLapTableViewCell: UITableViewCell {
    
    static let rowHeight: CGFloat = 72
    static let nibName = "WorkoutLapTableViewCell"
    
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    
    weak var aDelegate: WorkoutTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with workoutLap: WorkoutLap, row: Int) {
        dateLabel.text = "LAP \(row)"
        timeElapsedLabel.text = TimeInterval(workoutLap.totalTimeActive).formatted()
        distanceLabel.text = Utils.longDistanceString(meters: workoutLap.totalDistance)
        elevationLabel.text = "\(Utils.shortDistanceString(meters: workoutLap.netAltitude)) (+\(Utils.longDistanceString(meters: workoutLap.totalPositiveAltitude))"
        routeImageView.image = workoutLap.routeImage(rect: routeImageView.bounds)?.withRenderingMode(.alwaysTemplate)
    }
    
}
