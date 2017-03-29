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
    
    static var temperatureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        return formatter
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
    
    class func tempuratureString(kelvin: Double) -> String {
        let measurement = Measurement(value: kelvin, unit: UnitTemperature.kelvin)
        return temperatureFormatter.string(from: measurement)
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


extension Date {
    
    func timeAgo(_ numericDates: Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < self ? now : self
        let latest = (earliest == now) ? self : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
}
