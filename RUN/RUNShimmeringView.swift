//
//  RUNShimmeringView.swift
//  RUN
//
//  Created by Kurt Jensen on 3/23/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class RUNShimmeringView: FBShimmeringView {

    override func awakeFromNib() {
        super.awakeFromNib()
        if let view = subviews.first {
            contentView = view
        }
        shimmeringSpeed = 100
        shimmeringDirection = .left
        shimmeringPauseDuration = 0.5
        shimmeringOpacity = 0.6
        shimmeringAnimationOpacity = 1.0
        isShimmering = true
    }
    
}
