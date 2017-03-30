//
//  Settings.swift
//  RUN
//
//  Created by Kurt Jensen on 3/27/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class Settings: NSObject {
    
    class var isMetricDistanceUnits: Bool {
        return false
    }

    class Keys {
        static let AudioUpdateDistance = "AudioUpdateDistance"
        static let AudioUpdateTime = "AudioUpdateTime"
        static let theme = "theme"
        static let hasAgreedToTerms = "hasAgreedToTerms"
        static let iapSubscriptionExpiration = "iA"
        static let iapLifetime = "iB"
    }
    
    class var theme: Style.Theme {
        get {
            return Style.Theme(rawValue: UserDefaults.standard.integer(forKey: Keys.theme)) ?? .retro
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.theme)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Settings.Keys.theme), object: nil)
            Style.configure()
        }
    }
    
    class var audioUpdateDistance: Double {
        get {
            return UserDefaults.standard.double(forKey: Keys.AudioUpdateDistance)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.AudioUpdateDistance)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var audioUpdateTime: Double {
        get {
            return UserDefaults.standard.double(forKey: Keys.AudioUpdateTime)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.AudioUpdateTime)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var hasAgreedToTerms: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.hasAgreedToTerms)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasAgreedToTerms)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var expirationDatePRO: Date? {
        get {
            return UserDefaults.standard.object(forKey: Keys.iapSubscriptionExpiration) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.iapSubscriptionExpiration)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var isLifetimePRO: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.iapLifetime)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.iapLifetime)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var PRO: (isPRO: Bool, expirationDate: Date?) {
        guard !isLifetimePRO else {
            return (true, nil)
        }
        guard let expirationDatePRO = expirationDatePRO else {
            return (false, nil)
        }
        return (expirationDatePRO > Date(), expirationDatePRO)
    }
    
}
