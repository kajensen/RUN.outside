//
//  ReviewTableViewCell.swift
//  RedditStream
//
//  Created by Kurt Jensen on 3/19/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    static let nibName = "ReviewTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryView = UIImageView(image: #imageLiteral(resourceName: "Forward-48")) // TODO
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .disclosureIndicator
        let theme = Settings.theme
        titleLabel.textColor = theme.primaryTextColor
        titleLabel.font = Style.Font.regular(of: 17)
    }
    
}
