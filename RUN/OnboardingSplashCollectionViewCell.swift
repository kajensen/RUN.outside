//
//  OnboardingSplashCollectionViewCell.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import AVFoundation

protocol OnboardingSplashCollectionViewCellDelegate: class {
    func beginTapped(_ cell: OnboardingSplashCollectionViewCell)
}

class OnboardingSplashCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "OnboardingSplashCollectionViewCell"
    static let parallaxFactor: CGFloat = 25
    
    @IBOutlet weak var contentHolderView: UIView!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var player: AVPlayer?
    let avPlayerLayer = AVPlayerLayer()
    weak var delegate: OnboardingSplashCollectionViewCellDelegate?
    
    var parallaxOffset: CGPoint = .zero {
        didSet {
            let frame = videoView.bounds.offsetBy(dx: parallaxOffset.x, dy: parallaxOffset.y)
            videoView.frame = frame
            avPlayerLayer.frame = videoView.bounds
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
        playHero()
        prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avPlayerLayer.frame = videoView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        parallaxOffset = .zero
    }
    
    private func playHero() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        guard let videoURL = Bundle.main.url(forResource: "hero", withExtension: "mp4") else { return }
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        videoView.layer.addSublayer(avPlayerLayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayerLayer.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(OnboardingSplashCollectionViewCell.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    func loopVideo() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    @IBAction func beginTapped(_ sender: Any) {
        delegate?.beginTapped(self)
    }
    
}
