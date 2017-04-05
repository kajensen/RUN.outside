//
//  Style.swift
//  RedditStream
//
//  Created by Kurt Jensen on 2/28/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import SafariServices

class Style {
    
    class Font {
        class func regular(of size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size)
        }
        
        class func bold(of size: CGFloat) -> UIFont {
            return UIFont.boldSystemFont(ofSize: size)
        }
    }
    
    class func configure() {
        let theme = Settings.theme
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear

        if #available(iOS 10.3, *) {
            let iconName = theme.iconName
            if UIApplication.shared.alternateIconName != iconName {
                UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
                    print(error)
                })
            }
        }
        
        UIButton.appearance().tintColor = theme.primaryTextColor
        UIImageView.appearance().tintColor = theme.primaryTextColor

        
        //UIVisualEffectView.appearance().add

/*        // VIEWS
        UITableView.appearance().separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        UITableView.appearance().backgroundColor = theme.primaryBackgroundColor
        UITableView.appearance().tintColor = theme.secondaryTextColor
        UITableView.appearance().separatorColor = theme.primaryButtonColor
        // CELLS
        UITableViewCell.appearance().backgroundColor = theme.secondaryBackgroundColor
        UITableViewCell.appearance().contentView.backgroundColor = theme.secondaryBackgroundColor
        // BARS
        UINavigationBar.appearance().tintColor = theme.primaryButtonColor
        UINavigationBar.appearance().barStyle = theme.barStyle
        // SEARCH BAR
        UISearchBar.appearance().barTintColor = theme.primaryButtonColor
        UISearchBar.appearance().tintColor = theme.primaryButtonColor
        var bbAttributes = UIBarButtonItem.appearance().titleTextAttributes(for: .normal) ?? [:]
        bbAttributes[NSFontAttributeName] = font.regular(of: 16)
        UIBarButtonItem.appearance().setTitleTextAttributes(bbAttributes, for: .normal)
        UIToolbar.appearance().barTintColor = theme.barColor
        UIToolbar.appearance().tintColor = theme.primaryButtonColor
        UITabBar.appearance().tintColor = theme.primaryButtonColor
        UITabBar.appearance().barTintColor = theme.barColor
        if #available(iOS 10.0, *) {
            //UITabBar.appearance().unselectedItemTintColor = theme.secondaryTextColor
            UITabBarItem.appearance().badgeColor = Settings.theme.primaryButtonColor
        } else {
            // Fallback on earlier versions
        }
        var tbAttributes = UITabBarItem.appearance().titleTextAttributes(for: .normal) ?? [:]
        tbAttributes[NSFontAttributeName] = font.regular(of: 10)
        UITabBarItem.appearance().setTitleTextAttributes(tbAttributes, for: .normal)
        //
        var nbAttributes = UINavigationBar.appearance().titleTextAttributes ?? [:]
        nbAttributes[NSForegroundColorAttributeName] = theme.primaryBackgroundColor
        nbAttributes[NSFontAttributeName] = font.bold(of: 18)
        UINavigationBar.appearance().titleTextAttributes = nbAttributes
        UINavigationBar.appearance().tintColor = theme.barColor
        UINavigationBar.appearance().barTintColor = theme.primaryButtonColor
        //
        Comment.markdownParser.fontName = Settings.font.fontGroup?.regularName ?? UIFont.systemFont(ofSize: 17).fontName
*/
        for window in UIApplication.shared.windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }
    
    class Color {
        static let turquoiseGreen = UIColor(hex: "#1abc9c")
        static let emeraldGreen = UIColor(hex: "#2ecc71")
        static let peterRiverBlue = UIColor(hex: "#3498db")
        static let amethystPurple = UIColor(hex: "#9b59b6")
        static let seaGreen = UIColor(hex: "#16a085")
        static let nephritisGreen = UIColor(hex: "#27ae60")
        static let belizeHoleBlue = UIColor(hex: "#2980b9")
        static let wisteriaPurple = UIColor(hex: "#8e44ad")
        static let sunFlowerYellow = UIColor(hex: "#f1c40f")
        static let carrotOrange = UIColor(hex: "#e67e22")
        static let alizarinRed = UIColor(hex: "#e74c3c")
        static let cloudsGray = UIColor(hex: "#ecf0f1")
        static let sunOrange = UIColor(hex: "#f39c12")
        static let pumpkinOrange = UIColor(hex: "#d35400")
        static let pomegranateRed = UIColor(hex: "#c0392b")
        static let silverGray = UIColor(hex: "#bdc3c7")
        static let moonlightBlue = UIColor(hex: "#2c3e50")
        static let asphaltBlue = UIColor(hex: "#34495e")
        static let concreteGray = UIColor(hex: "#95a5a6")
        static let asbestosGray = UIColor(hex: "#7f8c8d")
        static let goldYellow = UIColor(hex: "#CCAC00")
    }
    
    enum Theme: Int {
        case retro, silver, mirkwood, electric
        static let all: [Theme] = [.retro, .silver, .mirkwood, .electric]

        var stringValue: String {
            switch self {
            case .retro:
                return "Retro"
            case .silver:
                return "Silver"
            case .mirkwood:
                return "Mirkwood"
            case .electric:
                return "Electric"
            }
        }
        
        var primaryTextColor: UIColor {
            switch self {
            case .retro, .silver:
                return UIColor.black
            case .mirkwood, .electric:
                return UIColor.white
            }
        }
        
        var secondaryTextColor: UIColor {
            switch self {
            case .retro, .silver:
                return UIColor.darkGray
            case .mirkwood, .electric:
                return UIColor.lightGray
            }
        }
        
        var alternateTextColor: UIColor {
            switch self {
            case .retro, .silver:
                return UIColor.lightGray
            case .mirkwood, .electric:
                return UIColor.gray
            }
        }
        
        var greenColor: UIColor {
            switch self {
            case .retro:
                return Color.turquoiseGreen
            case .silver:
                return Color.seaGreen
            case .mirkwood:
                return UIColor.green
            case .electric:
                return UIColor.green
            }
        }

        var yellowColor: UIColor {
            switch self {
            case .retro:
                return Color.sunFlowerYellow
            case .silver:
                return Color.sunFlowerYellow
            case .mirkwood:
                return Color.goldYellow
            case .electric:
                return UIColor.yellow
            }
        }
        
        var orangeColor: UIColor {
            switch self {
            case .retro:
                return Color.carrotOrange
            case .silver:
                return Color.sunOrange
            case .mirkwood:
                return Color.pumpkinOrange
            case .electric:
                return UIColor.orange
            }
        }
        
        var redColor: UIColor {
            switch self {
            case .retro:
                return Color.pomegranateRed
            case .silver:
                return Color.alizarinRed
            case .mirkwood:
                return Color.amethystPurple
            case .electric:
                return UIColor.red
            }
        }
        
        var barStyle: UIBarStyle {
            switch self {
            case .retro, .silver:
                return .default
            case .mirkwood, .electric:
                return .black
            }
        }
        
        var statusBarStyle: UIStatusBarStyle {
            switch self {
            case .retro, .silver:
                return .default
            case .mirkwood, .electric:
                return .lightContent
            }
        }
        
        var blurEffect: UIBlurEffect {
            switch self {
            case .retro, .silver:
                return UIBlurEffect(style: .light)
            case .mirkwood, .electric:
                return UIBlurEffect(style: .dark)
            }
        }
        
        var mapStyle: String {
            switch self {
            case .retro:
                return "map_retro"
            case .silver:
                return "map_silver"
            case .mirkwood:
                return "map_mirkwood"
            case .electric:
                return "map_electric"
            }
        }
        
        var iconName: String { // TODO
            switch self {
            case .retro:
                return "icon_retro"
            case .silver:
                return "icon_silver"
            case .mirkwood:
                return "icon_mirkwood"
            case .electric:
                return "icon_electric"
            }
        }
        
    }

}

class RSAlertController: UIAlertController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = Settings.theme.primaryTextColor
    }
}

class RSActivityViewController: UIActivityViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = Settings.theme.primaryTextColor
    }
}

class RSSafariViewController: SFSafariViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = Settings.theme.primaryTextColor
    }
}


protocol ThemeStyling: class {
    func configureTheme()
}

extension UIViewController: ThemeStyling {
    
    @objc func configureTheme() {
        // TODO
    }
    
    func registerForThemeChange() {
        configureTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.configureTheme), name: NSNotification.Name(rawValue: Settings.Keys.theme), object: nil)
    }
    
}

