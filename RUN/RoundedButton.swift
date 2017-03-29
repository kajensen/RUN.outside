//
//  RoundedButton.swift
//  RUN
//
//  Created by Kurt Jensen on 3/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
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
        layer.cornerRadius = cornerRadius
    }

}
