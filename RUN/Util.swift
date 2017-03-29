//
//  Util.swift
//  RUN
//
//  Created by Kurt Jensen on 3/27/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import MapKit

class Utils {
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    static var currencyNumberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    static var distanceFormatter: MKDistanceFormatter = {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = Settings.isMetricDistanceUnits ? .metric : .imperial
        return distanceFormatter
    }()
    
    class var distanceForLocale: Double {
        if Settings.isMetricDistanceUnits {
            return 1000
        } else {
            return 1609.34
        }
    }
    
    class func distanceString(meters: Double) -> String {
        return distanceFormatter.string(fromDistance: meters)
    }
    
}

extension NumberFormatter {
    
    class func currencyString(doubleValue: Double) -> String? {
        return currencyString(number: NSNumber(value: doubleValue))
    }
    
    class func currencyString(floatValue: Float) -> String? {
        return currencyString(number: NSNumber(value: floatValue))
    }
    
    class func currencyString(number: NSNumber) -> String? {
        return Utils.currencyNumberFormatter.string(from: number)
    }
    
    class func doubleValue(string: String) -> Double {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: string) {
            return result.doubleValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: string) {
                return result.doubleValue
            }
        }
        return 0
    }
    
}

extension Date {
    
    var formatted: String {
        return Utils.dateFormatter.string(from: self)
    }
    
    var formattedNoCommas: String {
        return formatted.replacingOccurrences(of: ",", with: "")
    }
    
}


extension TimeInterval {
    
    var dayComponent: Int {
        return self.hours / 24
    }
    var hours: Int {
        return Int(floor(((self / 60.0) / 60.0)))
    }
    var hourComponent: Int {
        return self.hours % 24
    }
    var minutes: Int {
        return Int(floor(self / 60.0))
    }
    var minuteComponent: Int {
        return minutes - (hours * 60)
    }
    var seconds: Int {
        return Int(floor(self))
    }
    var secondComponent: Int {
        return seconds - (minutes * 60)
    }
    var miliseconds: Int64 {
        return Int64((seconds * 1000) + milisecondComponent)
    }
    var milisecondComponent: Int {
        let (_, fracPart) = modf(self)
        return Int(fracPart * 10)
    }
    
    public func formatted() -> String {
        var text = ""
        if dayComponent > 0 {
            text += "\(dayComponent)d "
        }
        if hourComponent > 0 {
            text += String(format: "%@:", hourComponent < 10 ? "0" + String(hourComponent) : String(hourComponent))
        }
        text += String(format: "%@:", minuteComponent < 10 ? "0" + String(minuteComponent) : String(minuteComponent))
        if hourComponent > 0 {
            text += String(format: "%@", secondComponent < 10 ? "0" + String(secondComponent) : String(secondComponent))
        } else {
            text += String(format: "%@.", secondComponent < 10 ? "0" + String(secondComponent) : String(secondComponent))
            text += String(milisecondComponent)
        }
        return text
    }
    
}
