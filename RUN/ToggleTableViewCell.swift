//
//  ToggleTableViewCell.swift
//  RUN
//
//  Created by Kurt Jensen on 4/11/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol ToggleTableViewCellDelegate: class {
    func toggleChanged(_ cell: ToggleTableViewCell, toggle: UISwitch)
}

class ToggleTableViewCell: UITableViewCell {

    static let nibName = "ToggleTableViewCell"

    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: ToggleTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let theme = Settings.theme
        titleLabel.textColor = theme.primaryTextColor
    }
    
    @IBAction func toggleChanged(_ sender: Any) {
        delegate?.toggleChanged(self, toggle: toggle)
    }
    
}
