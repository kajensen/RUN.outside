//
//  WorkoutDataButton.swift
//  RUN
//
//  Created by Kurt Jensen on 4/4/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class WorkoutDataButton: UIButton {

    @IBInspectable
    var workoutDataType: Int = 0
    
    var workoutData: WorkoutData {
        return WorkoutData(rawValue: workoutDataType) ?? .speed
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
