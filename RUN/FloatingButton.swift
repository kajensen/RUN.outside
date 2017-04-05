//
//  FloatingButton.swift
//  RUN
//
//  Created by Kurt Jensen on 4/5/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class FloatingButton: UIButton {
    
    static let animationDuration: TimeInterval = 0.05
    
    var fillColor: UIColor = UIColor.black {
        didSet {
            circleLayer.fillColor = fillColor.cgColor
        }
    }
    
    private let circleLayer = CAShapeLayer()
    private let whiteLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.lineWidth = 1
        layer.insertSublayer(circleLayer, at: 0)
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        addTarget(self, action: #selector(FloatingButton.touchDown), for: .touchDown)
        addTarget(self, action: #selector(FloatingButton.touchUp), for: .touchUpInside)
        addTarget(self, action: #selector(FloatingButton.touchUp), for: .touchUpOutside)
        addTarget(self, action: #selector(FloatingButton.touchUp), for: .touchCancel)
        let theme = Settings.theme
        tintColor = UIColor.white
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func touchDown() {
        animateDown()
    }
    
    func touchUp() {
        perform(#selector(FloatingButton.animateUp), with: nil, afterDelay: FloatingButton.animationDuration)
    }
    
    func animateDown(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: FloatingButton.animationDuration, animations: { [weak self] in
            self?.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75)
            self?.layoutIfNeeded()
            }, completion: completion)
    }
    
    func animateUp(completion: ((Bool) -> Void)? = nil) {
        if transform == CGAffineTransform.identity {
            animateDown(completion: { (finished) in
                self.animateUp()
            })
        } else {
            UIView.animate(withDuration: FloatingButton.animationDuration, animations: { [weak self] in
                self?.transform = CGAffineTransform.identity
                self?.layoutIfNeeded()
                }, completion: completion)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }
    
}
