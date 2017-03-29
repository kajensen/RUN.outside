//
//  ActionTableViewCell.swift
//  RedditStream
//
//  Created by Kurt Jensen on 3/18/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class ActionTableViewCell: UITableViewCell {
    
    static let nibName = "ActionTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        accessoryType = .disclosureIndicator
        let theme = Settings.theme
        textLabel?.textColor = theme.primaryTextColor
        textLabel?.font = Style.Font.regular(of: 17)
        detailTextLabel?.textColor = theme.secondaryTextColor
        detailTextLabel?.font = Style.Font.regular(of: 15)
    }
    
}
