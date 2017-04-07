//
//  OnboardingViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import AVFoundation

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: OnboardingSplashCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: OnboardingSplashCollectionViewCell.nibName)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
            layout.itemSize = collectionView.bounds.size
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingSplashCollectionViewCell.nibName, for: indexPath) as! OnboardingSplashCollectionViewCell
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? OnboardingSplashCollectionViewCell {
            cell.player?.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? OnboardingSplashCollectionViewCell {
            cell.player?.pause()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let percent = offsetX/scrollView.frame.size.width
        if !percent.isNaN {
            let index = Int(percent)
            pageControl.currentPage = max(index, 0)
        }
        // parallax
        for cell in collectionView.visibleCells {
            if let cell = cell as? OnboardingSplashCollectionViewCell {
                let bounceOffset = min(0, collectionView.contentOffset.x)
                cell.contentOffset = CGPoint(x: bounceOffset, y: 0)
                let xOffset = ((collectionView.contentOffset.x - cell.frame.origin.x) / cell.frame.width) * OnboardingSplashCollectionViewCell.parallaxFactor
                cell.parallaxOffset = CGPoint(x: xOffset, y: 0)
            }
        }
    }
    
}

extension OnboardingViewController: OnboardingSplashCollectionViewCellDelegate {
    
    func beginTapped(_ cell: OnboardingSplashCollectionViewCell) {
        let contentOffset = CGPoint(x: collectionView.bounds.width, y: 0)
        collectionView.setContentOffset(contentOffset, animated: true)
    }
    
}
