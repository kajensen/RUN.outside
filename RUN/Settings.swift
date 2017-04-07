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
        static let LapDistance = "LapDistance"
        static let SpeedRateSlow = "SpeedRateSlow"
        static let SpeedRateMedium = "SpeedRateMedium"
        static let SpeedRateFast = "SpeedRateFast"
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
    
    class var lapDistance: Double {
        get {
            return UserDefaults.standard.double(forKey: Keys.LapDistance)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.LapDistance)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var lapDistances: [Double] {
        var lapDistances: [Double] = []
        for i in [0, 0.1, 0.2, 0.5, 1, 1.5, 2, 2.5, 3, 4, 5, 10] {
            lapDistances.append(Utils.longDistanceForLocale*i)
        }
        return lapDistances
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
    
    class var audioUpdateDistances: [Double] {
        var audioUpdateDistances: [Double] = []
        for i in [0, 0.1, 0.2, 0.5, 1, 1.5, 2, 2.5, 3, 4, 5, 10] {
            audioUpdateDistances.append(Utils.longDistanceForLocale*i)
        }
        return audioUpdateDistances
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
    
    class var audioUpdateTimes: [TimeInterval] {
        return [0, 30, 60, 90, 120, 180, 240, 300, 360, 420, 480, 540, 600, 900, 1800]
    }
    
    class var speedRates: [Double] {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    }
    
    class var speedRateSlow: Double {
        get {
            return max(UserDefaults.standard.double(forKey: Keys.SpeedRateSlow), 2)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.SpeedRateSlow)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var speedRateMedium: Double {
        get {
            return max(UserDefaults.standard.double(forKey: Keys.SpeedRateMedium), 5)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.SpeedRateMedium)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var speedRateFast: Double {
        get {
            return max(UserDefaults.standard.double(forKey: Keys.SpeedRateFast), 10)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.SpeedRateFast)
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
