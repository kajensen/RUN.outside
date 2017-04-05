//
//  WorkoutDataSpanButton.swift
//  RUN
//
//  Created by Kurt Jensen on 4/4/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class WorkoutDataSpanButton: UIButton {

    @IBInspectable
    var workoutDataSpanType: Int = 0
    
    var workoutDataSpan: WorkoutDataSpan {
        return WorkoutDataSpan(rawValue: workoutDataSpanType) ?? .week
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        // TODO
    }
    
}

