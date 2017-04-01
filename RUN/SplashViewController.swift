//
//  SplashViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/30/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import AVFoundation

class SplashViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    
    var player: AVPlayer?
    let avPlayerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showVideo()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SplashViewController.viewTapped(_:)))
        videoView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func viewTapped(_ tapGesture: UITapGestureRecognizer) {
        switch (tapGesture.state) {
        case .ended:
            showMap()
            break
        default:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        avPlayerLayer.frame = videoView.bounds
        super.viewDidLayoutSubviews()
    }
    
    func showVideo() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        guard let videoURL = Bundle.main.url(forResource: "hero", withExtension: "mp4") else { return }
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        videoView.layer.addSublayer(avPlayerLayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayerLayer.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(SplashViewController.showMap), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        player?.play()
    }

    func showMap() {
        guard presentedViewController == nil else { return }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: MapViewController.storyboardId) as? MapViewController else {
            return
        }
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
}
