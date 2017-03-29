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
    
    func configure(distance: Double) {
        // TODO
    }
    
    func configure(time: Double) {
        // TODO
    }
    
    /*
    func configure(theme: Style.Theme) {
        titleLabel.text = "Theme"
        subTitleLabel.text = theme.stringValue
        iconImageView.image = UIImage(named: "icon_theme")
    }
    
    func configure(threadDelayRate: Settings.ThreadDelayRate) {
        titleLabel.text = "Stream Delay"
        subTitleLabel.text = threadDelayRate.stringValue
        iconImageView.image = UIImage(named: "icon_delay")
    }
    
    func configure(recentHistoryInterval: Settings.RecentHistoryInterval) {
        titleLabel.text = "Expire Following After"
        subTitleLabel.text = recentHistoryInterval.stringValue
        iconImageView.image = UIImage(named: "icon_threads")
    }*/
    
}
