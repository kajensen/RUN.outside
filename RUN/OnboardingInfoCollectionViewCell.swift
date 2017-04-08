//
//  OnboardingInfoCollectionViewCell.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class OnboardingInfoCollectionViewCell: UICollectionViewCell, ParallaxCell {
    
    static let nibName = "OnboardingInfoCollectionViewCell"
    static let parallaxFactor: CGFloat = 25
    
    @IBOutlet weak var contentHolderView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: OnboardingSplashCollectionViewCellDelegate?
    
    var parallaxOffset: CGPoint = .zero {
        didSet {
            let frame = imageView.bounds.offsetBy(dx: parallaxOffset.x, dy: parallaxOffset.y)
            imageView.frame = frame
        }
    }
    
    var contentOffset: CGPoint = .zero {
        didSet {
            guard let superview = contentHolderView.superview else {
                return
            }
            var frame = superview.bounds
            frame.origin.x = contentOffset.x
            frame.size.width += abs(contentOffset.x)
            contentHolderView.frame = frame
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        parallaxOffset = .zero
    }
    
}
