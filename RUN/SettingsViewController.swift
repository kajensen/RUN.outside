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
        versionLabel.text = UIApplication.versionString
        return versionLabel
    }()
    
    lazy var feedbackButton: UIButton = {
        let feedbackButton = UIButton(type: .system)
        feedbackButton.setImage(UIImage(named: "icon_feedback"), for: .normal)
        feedbackButton.addTarget(self, action: #selector(SettingsViewController.sendEmail), for: .touchUpInside)
        return feedbackButton
    }()
    
    lazy var aboutButton: UIButton = {
        let aboutButton = UIButton(type: .system)
        aboutButton.setImage(UIImage(named: "icon_about"), for: .normal)
        aboutButton.addTarget(self, action: #selector(SettingsViewController.showAbout), for: .touchUpInside)
        return aboutButton
    }()
    
    lazy var tableFooterView: UIView = {
        let tableFooterView =  UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 50)))
        self.versionLabel.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView.addSubview(self.versionLabel)
        self.versionLabel.centerXAnchor.constraint(equalTo: tableFooterView.centerXAnchor).isActive = true
        self.versionLabel.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor, constant: -8).isActive = true
        self.feedbackButton.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView.addSubview(self.feedbackButton)
        self.feedbackButton.trailingAnchor.constraint(equalTo: tableFooterView.trailingAnchor, constant: -15).isActive = true
        self.feedbackButton.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor, constant: -8).isActive = true
        self.aboutButton.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView.addSubview(self.aboutButton)
        self.aboutButton.leadingAnchor.constraint(equalTo: tableFooterView.leadingAnchor, constant: 15).isActive = true
        self.aboutButton.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor, constant: -8).isActive = true
        return tableFooterView
    }()
    
    var preferredViewSize: CGSize? {
        guard isViewLoaded else {
            return nil
        }
        return CGSize(width: view.bounds.width, height: tableView.contentSize.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerForThemeChange()
    }
    
    override func configureTheme() {
        let theme = Settings.theme
        versionLabel.textColor = theme.secondaryTextColor
        versionLabel.font = Style.Font.regular(of: 12)
        if let bgView = view as? BGView {
            bgView.effect = theme.blurEffect
        }
        tableView.reloadData()
        tableView.separatorColor = UIColor.black
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.settingsViewControllerTappedClose(self)
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
            return "WORKOUT SETTINGS"
        case 2:
            return "DATA"
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
            return 1
        case 1:
            return 4
        case 2:
            return 1
        case 3:
            return 1
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
                cell.configure(theme: Settings.theme)
                break
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomizationTableViewCell.nibName, for: indexPath) as! CustomizationTableViewCell
            switch indexPath.row {
            case 0:
                cell.configure(audioUpdateTime: Settings.audioUpdateTime)
            case 1:
                cell.configure(audioUpdateDistance: Settings.audioUpdateDistance)
            case 2:
                cell.configure(speedRateSlow: Settings.speedRateSlow, speedRateMedium: Settings.speedRateMedium, speedRateFast: Settings.speedRateFast)
            default:
                cell.configure(lapDistance: Settings.lapDistance)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.nibName, for: indexPath)
            switch indexPath.row {
            default:
                cell.textLabel?.text = "Import/Export data"
                break
            }
            return cell
        case 3:
            switch indexPath.row {
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.nibName, for: indexPath)
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
            case 0:
                selectTheme(cell)
            default:
                break
            }
        case 1:
            guard let cell = tableView.cellForRow(at: indexPath) as? CustomizationTableViewCell else {
                return
            }
            switch indexPath.row {
            case 0:
                selectUpdateTime(cell)
            case 1:
                selectUpdateDistance(cell)
            case 2:
                selectSpeedRates(cell)
            default:
                selectLapDistance(cell)
            }
        case 2:
            switch indexPath.row {
            default:
                showDataVC()
            }
            return
        default:
            break
        }
    }
    
    func showDataVC() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DataViewController.storyboardId) else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAbout() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: AboutViewController.storyboardId) else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func selectTheme(_ cell: CustomizationTableViewCell) {
        let vc = SelectThemeTableViewController()
        vc.delegate = self
        addPopover(to: vc, from: cell, size: CGSize(width: 120, height: CGFloat(vc.themes.count)*SelectThemeTableViewController.rowHeight))
        present(vc, animated: true, completion: nil)
    }
    
    private func selectUpdateTime(_ cell: CustomizationTableViewCell) {
        let vc = SelectUpdateTimeTableViewController()
        vc.delegate = self
        addPopover(to: vc, from: cell, size: CGSize(width: 120, height: CGFloat(vc.updateTimes.count)*SelectUpdateTimeTableViewController.rowHeight))
        present(vc, animated: true, completion: nil)
    }
    
    private func selectLapDistance(_ cell: CustomizationTableViewCell) {
        let vc = SelectLapDistanceTableViewController()
        vc.delegate = self
        addPopover(to: vc, from: cell, size: CGSize(width: 120, height: CGFloat(vc.lapDistances.count)*SelectLapDistanceTableViewController.rowHeight))
        present(vc, animated: true, completion: nil)
    }

    private func selectUpdateDistance(_ cell: CustomizationTableViewCell) {
        let vc = SelectUpdateDistanceTableViewController()
        vc.delegate = self
        addPopover(to: vc, from: cell, size: CGSize(width: 120, height: CGFloat(vc.updateDistances.count)*SelectUpdateDistanceTableViewController.rowHeight))
        present(vc, animated: true, completion: nil)
    }
    
    private func selectSpeedRates(_ cell: CustomizationTableViewCell) {
        let vc = SelectSpeedScaleViewController()
        vc.delegate = self
        addPopover(to: vc, from: cell, size: CGSize(width: 300, height: 200))
        present(vc, animated: true, completion: nil)
    }
    
    func addPopover(to vc: UIViewController, from cell: CustomizationTableViewCell, size: CGSize) {
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = size
        vc.popoverPresentationController?.sourceView = cell.subTitleLabel
        vc.popoverPresentationController?.sourceRect = CGRect(x: cell.subTitleLabel.bounds.width*0.5, y: 0, width: 0, height: cell.subTitleLabel.bounds.height)
        vc.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        vc.popoverPresentationController?.canOverlapSourceViewRect = false
        vc.popoverPresentationController?.delegate = self
    }
    
}

extension SettingsViewController: SelectThemeTableViewControllerDelegate {
    func selectThemeTableViewControllerDidSelect(_ vc: SelectThemeTableViewController, theme: Style.Theme) {
        vc.dismiss(animated: true) {
            Settings.theme = theme
        }
    }
}

extension SettingsViewController: SelectUpdateTimeTableViewControllerDelegate {
    func selectUpdateTimeTableViewControllerDidSelect(_ vc: SelectUpdateTimeTableViewController, updateTime: TimeInterval) {
        vc.dismiss(animated: true) {
            Settings.audioUpdateTime = updateTime
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
    }
}

extension SettingsViewController: SelectUpdateDistanceTableViewControllerDelegate {
    func selectUpdateDistanceTableViewControllerDidSelect(_ vc: SelectUpdateDistanceTableViewController, updateDistance: Double) {
        vc.dismiss(animated: true) {
            Settings.audioUpdateDistance = updateDistance
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
        }
    }
}

extension SettingsViewController: SelectLapDistanceTableViewControllerDelegate {
    func selectLapDistanceTableViewControllerDidSelect(_ vc: SelectLapDistanceTableViewController, lapDistance: Double) {
        vc.dismiss(animated: true) {
            Settings.lapDistance = lapDistance
            self.tableView.reloadRows(at: [IndexPath(row: 3, section: 1)], with: .automatic)
        }
    }
}

extension SettingsViewController: SelectSpeedScaleViewControllerDelegate {
    func selectSpeedScaleViewControllerDidSelect(_ vc: SelectSpeedScaleViewController, speedRateSlow: Double, speedRateMedium: Double, speedRateFast: Double) {
        // will be called when already dismissing SelectSpeedScaleViewController
        Settings.speedRateSlow = speedRateSlow
        Settings.speedRateMedium = speedRateMedium
        Settings.speedRateFast = speedRateFast
        tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setToRecipients([Constants.email])
            vc.setSubject("Feedback")
            present(vc, animated: true, completion: nil)
        } else {
            showAlert(title: "You can contact us at \(Constants.email)")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { () -> Void in
            if (result == .sent) {
                self.showAlert(title: "Email Sent")
            }
        }
        
    }
    
}
