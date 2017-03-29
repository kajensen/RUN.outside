//
//  RoundedView.swift
//  RUN
//
//  Created by Kurt Jensen on 3/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height)/2
    }
    
}
