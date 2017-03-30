//
//  SelectThemeTableViewController.swift
//  RedditStream
//
//  Created by Kurt Jensen on 3/15/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

protocol SelectThemeTableViewControllerDelegate: class {
    func selectThemeTableViewControllerDidSelect(_ vc: SelectThemeTableViewController, theme: Style.Theme)
}

class SelectThemeTableViewController: UITableViewController {
    
    var selectedTheme: Style.Theme = Settings.theme
    let themes = Style.Theme.all
    weak var delegate: SelectThemeTableViewControllerDelegate?
    
    static let rowHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        tableView.rowHeight = SelectThemeTableViewController.rowHeight
        //tableView.backgroundColor = Settings.theme.primaryTextColor
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let theme = themes[indexPath.row]
        cell.textLabel?.text = theme.stringValue
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        if theme == selectedTheme {
            cell.textLabel?.textColor = Settings.theme.primaryTextColor
        } else {
            cell.textLabel?.textColor = Settings.theme.secondaryTextColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let theme = themes[indexPath.row]
        delegate?.selectThemeTableViewControllerDidSelect(self, theme: theme)
    }
    
}

