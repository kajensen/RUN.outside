//
//  BGView.swift
//  RUN
//
//  Created by Kurt Jensen on 3/23/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class BGView: UIView {
    
    var effect = Settings.theme.blurEffect {
        didSet {
            updateEffect()
        }
    }
    
    private var visualEffectView: UIVisualEffectView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = UIVisualEffectView(effect: effect)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, at: 0)
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        /*layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)*/
        visualEffectView = view
    }
    
    func updateEffect() {
        UIView.animate(withDuration: 0.5) { 
            self.visualEffectView?.effect = self.effect
        }
    }

}
