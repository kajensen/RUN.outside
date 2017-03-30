//
//  CustomizationTableViewCell.swift
//  RedditStream
//
//  Created by Kurt Jensen on 2/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class CustomizationTableViewCell: UITableViewCell {
    
    static let nibName = "CustomizationTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var subTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let theme = Settings.theme
        titleLabel.textColor = theme.primaryTextColor
        titleLabel.font = Style.Font.regular(of: 17)
        subTitleLabel.textColor = theme.secondaryTextColor
        subTitleLabel.font = Style.Font.regular(of: 15)
    }
    
    func configure(audioUpdateDistance: Double) {
        titleLabel.text = "Coach Update every..."
        if audioUpdateDistance > 0 {
            subTitleLabel.text = Utils.distanceString(meters: audioUpdateDistance)
        } else {
            subTitleLabel.text = "Off"
        }
        iconImageView.image = UIImage(named: "icon_time")
    }
    
    func configure(audioUpdateTime: Double) {
        titleLabel.text = "Coach Update every..."
        if audioUpdateTime > 0 {
            subTitleLabel.text = TimeInterval(audioUpdateTime).formatted(false)
        } else {
            subTitleLabel.text = "Off"
        }
        iconImageView.image = UIImage(named: "icon_time")
    }
    
    func configure(speedRateSlow: Double, speedRateMedium: Double, speedRateFast: Double) {
        titleLabel.text = "Speeds"
        subTitleLabel.text = "\(Utils.distanceRateString(unitsPerHour: speedRateSlow)) > \(Utils.distanceRateString(unitsPerHour: speedRateMedium)) > \(Utils.distanceRateString(unitsPerHour: speedRateFast))"
        iconImageView.image = UIImage(named: "icon_time")
    }
    
    func configure(theme: Style.Theme) {
        titleLabel.text = "Theme"
        subTitleLabel.text = theme.stringValue
        iconImageView.image = UIImage(named: "icon_theme")
    }
    
}
