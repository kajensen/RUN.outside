//
//  SettingsViewController.swift
//  RUN
//
//  Created by Kurt Jensen on 3/25/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import RealmSwift
import iRate
import MessageUI

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerTappedClose(_ vc: SettingsViewController)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SettingsViewControllerDelegate?

    lazy var versionLabel: UILabel = {
        let versionLabel = UILabel()
        versionLabel.font = Style.Font.regular(of: 12)
        versionLabel.numberOfLines = 0
        versionLabel.textAlignment = .center
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        }
        return versionLabel
    }()
    
    lazy var tableFooterView: UIView = {
        let tableFooterView =  UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 50)))
        self.versionLabel.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView.addSubview(self.versionLabel)
        self.versionLabel.centerXAnchor.constraint(equalTo: tableFooterView.centerXAnchor).isActive = true
        self.versionLabel.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor).isActive = true
        return tableFooterView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //registerForThemeChange()
    }
    
    var preferredViewSize: CGSize? {
        guard isViewLoaded else {
            return nil
        }
        return CGSize(width: view.bounds.width, height: tableView.contentSize.height)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.settingsViewControllerTappedClose(self)
    }

    override func configureTheme() {
        let theme = Settings.theme
        versionLabel.textColor = theme.secondaryTextColor
        versionLabel.font = Style.Font.regular(of: 12)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ReviewTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: ReviewTableViewCell.nibName)
        tableView.register(UINib(nibName: ActionTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: ActionTableViewCell.nibName)
        tableView.register(UINib(nibName: CustomizationTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: CustomizationTableViewCell.nibName)
        tableView.rowHeight = 44
        tableView.tableFooterView = tableFooterView
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "CUSTOMIZATION"
        case 1:
            return "SETTINGS"
        case 2:
            return "INFO"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 28))
        headerView.backgroundColor = UIColor.clear
        let titleLabel = UILabel()
        titleLabel.font = Style.Font.regular(of: 12)
        titleLabel.textColor = Settings.theme.secondaryTextColor
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4).isActive = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomizationTableViewCell.nibName, for: indexPath) as! CustomizationTableViewCell
            switch indexPath.row {
            default:
                //cell.configure(font: Settings.font)
                break
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomizationTableViewCell.nibName, for: indexPath) as! CustomizationTableViewCell
            switch indexPath.row {
            default:
                //cell.configure(recentHistoryInterval: Settings.defaultRecentHistoryInterval)
                break
            }
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.nibName, for: indexPath)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.nibName, for: indexPath)
                cell.textLabel?.text = "Feedback/Improvements"
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.nibName, for: indexPath)
                cell.textLabel?.text = "Terms of Service"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.nibName, for: indexPath)
                cell.textLabel?.text = "Privacy Policy"
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            guard let cell = tableView.cellForRow(at: indexPath) as? CustomizationTableViewCell else {
                return
            }
            switch indexPath.row {
                // TODO
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                UIApplication.shared.openURL(iRate.sharedInstance().ratingsURL)
            case 1:
                sendEmail()
                break
            default:
                // TODO

                break
            }
            return
        default:
            return
        }
    }
    /*
    private func selectTheme(_ cell: CustomizationTableViewCell) {
        let vc = SelectThemeTableViewController()
        vc.delegate = self
        vc.selectedTheme = Settings.theme
        addPopover(to: vc, from: cell, size: CGSize(width: 120, height: CGFloat(Style.Theme.all.count)*SelectThemeTableViewController.rowHeight))
        present(vc, animated: true, completion: nil)
    }
    
    
    private func selectCommentSort(_ cell: CustomizationTableViewCell) {
        let vc = SelectCommentSortTableViewController()
        vc.delegate = self
        vc.selectedCommentSort = Settings.defaultCommentSort
        addPopover(to: vc, from: cell, size: CGSize(width: 120, height: CGFloat(Settings.CommentSort.all.count)*SelectCommentSortTableViewController.rowHeight))
        present(vc, animated: true, completion: nil)
    }*/

    func addPopover(to vc: UIViewController, from cell: CustomizationTableViewCell, size: CGSize) {
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = size
        vc.popoverPresentationController?.sourceView = cell.subTitleLabel
        vc.popoverPresentationController?.sourceRect = CGRect(x: cell.subTitleLabel.bounds.width*0.5, y: 0, width: 0, height: cell.subTitleLabel.bounds.height)
        vc.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        vc.popoverPresentationController?.canOverlapSourceViewRect = false
        //vc.popoverPresentationController?.delegate = self
    }
    
}

/*
extension SettingsViewController: SelectCommentSortTableViewControllerDelegate {
    func selectCommentSortTableViewControllerDidSelect(_ vc: SelectCommentSortTableViewController, commentSort: Settings.CommentSort) {
        if commentSort == .mine {
            guard User.currentUser != nil else {
                promptLogin("view your comments")
                return
            }
        }
        Settings.defaultCommentSort = commentSort
        vc.dismiss(animated: true, completion: nil)
        tableView.reloadRows(at: [IndexPath(row: 1, section: 3)], with: .automatic)
    }
}

extension SettingsViewController: SelectThemeTableViewControllerDelegate {
    func selectThemeTableViewControllerDidSelect(_ vc: SelectThemeTableViewController, theme: Style.Theme) {
        vc.dismiss(animated: true) {
            Settings.theme = theme
        }
    }
}

extension SettingsViewController: SelectRecentHistoryIntervalTableViewControllerDelegate {
    func selectRecentHistoryIntervalTableViewControllerDidSelect(_ vc: SelectRecentHistoryIntervalTableViewController, interval: Settings.RecentHistoryInterval) {
        Settings.defaultRecentHistoryInterval = interval
        tableView.reloadRows(at: [IndexPath(row: 3, section: 3)], with: .automatic)
    }
}*/

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            // TODO vc.setToRecipients([Constants.email])
            vc.setSubject("Feedback")
            present(vc, animated: true, completion: nil)
        } else {
            //showAlert(title: "You can contact us at \(Constants.email)")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { () -> Void in
            if (result == .sent) {
                //self.showAlert(title: "Email Sent")
            }
        }
        
    }
    
}
