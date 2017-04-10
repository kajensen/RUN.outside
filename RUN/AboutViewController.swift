//
//  AboutViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 4/9/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    static let storyboardId = "AboutViewController"
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        textView.dataDetectorTypes = [.link, .address]
        setupText()
    }
    
    private func setupText() {
        let theme = Settings.theme
        textView.tintColor = theme.primaryTextColor
        let titleAttributes = [NSFontAttributeName: Style.Font.bold(of: 17), NSForegroundColorAttributeName: theme.primaryTextColor]
        //let textAttributes = [NSFontAttributeName: Style.Font.regular(of: 14), NSForegroundColorAttributeName: theme.secondaryTextColor]
        let smallTextAttributes = [NSFontAttributeName: Style.Font.regular(of: 12), NSForegroundColorAttributeName: theme.secondaryTextColor]
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "Workout Settings\n\n", attributes: titleAttributes))
        string.append(NSAttributedString(string: "Timed Updates: These audio updates happen every time you run for a set time.\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "Distance Updates: These audio updates happen every time you run a set distance.\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "My Speeds: These speed thresholds determine how your map colors your run path.\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "Start New Lap: This is the set distance to automatically start a new lap for later analysis.\n\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "Data\n\n", attributes: titleAttributes))
        string.append(NSAttributedString(string: "You can export your data in json or csv formats.\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "We hope to add import features from other running trackers- let us know what you want!\n\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "Info\n\n", attributes: titleAttributes))
        string.append(NSAttributedString(string: "Privacy Policy: \(Constants.privacyURL.absoluteString)\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "Terms of Service: \(Constants.termsURL.absoluteString)\n\n", attributes: smallTextAttributes))
        string.append(NSAttributedString(string: "We hope you are enjoying RUN! Email us at \(Constants.email) for feedback/suggestions.", attributes: smallTextAttributes))
        textView.attributedText = string
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
