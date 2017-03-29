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

        for window in UIApplication.shared.windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }*/
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
        case reddit, moonlight, trees, narwhal, bacon, gold
        static var all: [Theme] {
            var all: [Theme] = [.reddit, .moonlight, .trees, .narwhal, .bacon]
            if Settings.PRO.isPRO {
                all.append(.gold)
            }
            return all
        }
        var stringValue: String {
            switch self {
            case .reddit:
                return "Reddit"
            case .moonlight:
                return "Moonlight"
            case .trees:
                return "Trees"
            case .narwhal:
                return "Narwhal"
            case .bacon:
                return "Bacon"
            case .gold:
                return "Gold"
            }
        }
        
        var primaryTextColor: UIColor {
            switch self {
            case .reddit, .trees, .narwhal, .bacon:
                return UIColor.black
            case .moonlight:
                return UIColor.white
            case .gold:
                return Color.goldYellow
            }
        }
        
        var secondaryTextColor: UIColor {
            return Color.silverGray
        }
        
        var primaryBackgroundColor: UIColor {
            switch self {
            case .reddit, .trees, .narwhal, .bacon, .gold:
                return Color.cloudsGray
            case .moonlight:
                return Color.moonlightBlue
            }
        }
        
        var secondaryBackgroundColor: UIColor {
            switch self {
            case .reddit, .trees, .narwhal, .bacon, .gold:
                return UIColor.white
            case .moonlight:
                return Color.asphaltBlue
            }
        }
        
        var primaryButtonColor: UIColor {
            switch self {
            case .reddit:
                return Color.belizeHoleBlue
            case .moonlight:
                return Color.silverGray
            case .trees:
                return Color.turquoiseGreen
            case .narwhal:
                return Color.peterRiverBlue
            case .bacon:
                return Color.carrotOrange
            case .gold:
                return Color.sunFlowerYellow
            }
        }
        
        var secondaryButtonColor: UIColor {
            return primaryButtonColor
        }
        
        var upvoteColor: UIColor {
            switch self {
            case .reddit:
                return Color.carrotOrange
            case .moonlight:
                return Color.sunOrange
            case .trees:
                return Color.emeraldGreen
            case .narwhal:
                return Color.sunOrange
            case .bacon:
                return Color.turquoiseGreen
            case .gold:
                return Color.turquoiseGreen
            }
        }
        
        var downvoteColor: UIColor {
            switch self {
            case .reddit:
                return Color.peterRiverBlue
            case .moonlight:
                return Color.amethystPurple
            case .trees:
                return Color.peterRiverBlue
            case .narwhal:
                return Color.amethystPurple
            case .bacon:
                return Color.peterRiverBlue
            case .gold:
                return Color.peterRiverBlue
            }
        }
        
        var barColor: UIColor {
            return primaryBackgroundColor
        }
        
        var barStyle: UIBarStyle {
            return .black
        }
        
        var statusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        var alertTextColor: UIColor {
            switch self {
            case .moonlight:
                return primaryBackgroundColor
            default:
                return primaryButtonColor
            }
        }
        
        var mapStyle: String {
            switch self {
            case .moonlight:
                return "map_mirkwood"
            default:
                return "map_retro"
            }
        }
        
    }

}

class RSAlertController: UIAlertController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = Settings.theme.alertTextColor
    }
}

class RSActivityViewController: UIActivityViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = Settings.theme.alertTextColor
    }
}

class RSSafariViewController: SFSafariViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.tintColor = Settings.theme.primaryButtonColor
        navigationController?.navigationBar.tintColor = Settings.theme.primaryButtonColor
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

