//
//  Util.swift
//  RUN
//
//  Created by Kurt Jensen on 3/27/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit
import MapKit

extension UIViewController {
    
    func showAlert(title: String? = nil, message: String? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
            completion?()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: Error?, completion: (() -> Void)? = nil) {
        showErrorMessageAlert(message: error?.localizedDescription, completion: completion)
    }
    
    func showErrorMessageAlert(message: String?, completion: (() -> Void)? = nil) {
        showAlert(title: "Error", message: message, completion: completion)
    }
    
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
        
}

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
    
    static var distanceFormatter: LengthFormatter = {
        let distanceFormatter = LengthFormatter()
        distanceFormatter.numberFormatter.minimumFractionDigits = 1
        distanceFormatter.numberFormatter.maximumFractionDigits = 2
        return distanceFormatter
    }()
    
    static var distanceRateFormatter: MKDistanceFormatter = {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = Settings.isMetricDistanceUnits ? .metric : .imperial
        distanceFormatter.unitStyle = .abbreviated
        return distanceFormatter
    }()
    
    static var temperatureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter = numberFormatter
        return formatter
    }()
    
    class var longDistanceForLocale: Double {
        if Settings.isMetricDistanceUnits {
            return 1000
        } else {
            return 1609.34
        }
    }
    
    class var shortDistanceForLocale: Double {
        if Settings.isMetricDistanceUnits {
            return 1
        } else {
            return 3.28084
        }
    }
    
    class func shortDistanceString(meters: Double) -> String {
        let unit: LengthFormatter.Unit = Settings.isMetricDistanceUnits ? .meter : .foot
        let distanceInLocale = meters*shortDistanceForLocale
        return distanceFormatter.string(fromValue: distanceInLocale, unit: unit)
    }
    
    class func longDistanceString(meters: Double) -> String {
        let unit: LengthFormatter.Unit = Settings.isMetricDistanceUnits ? .kilometer : .mile
        let distanceInLocale = meters/longDistanceForLocale
        return distanceFormatter.string(fromValue: distanceInLocale, unit: unit)
    }
    
    class func longDistanceUnitString() -> String {
        return Settings.isMetricDistanceUnits ? "kilometers" : "miles"
    }
    
    class func distanceRateString(unitsPerHour: Double) -> String {
        return "\(distanceRateFormatter.string(fromDistance: unitsPerHour*longDistanceForLocale))/hr"
    }
    
    class func distanceRateString(metersPerSecond: Double) -> String {
        return "\(distanceRateFormatter.string(fromDistance: metersPerSecond*longDistanceForLocale))/hr"
    }
    
    class func metersPerSecond(unitsPerHour: Double) -> Double {
        return (longDistanceForLocale*unitsPerHour)/3600
    }
    
    class func unitsPerHour(metersPerSecond: Double) -> Double {
        return (metersPerSecond*3600)/longDistanceForLocale
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
    
    public func formatted(_ includeMillisecond: Bool = true) -> String {
        var text = ""
        if dayComponent > 0 {
            text += "\(dayComponent)d "
        }
        if hourComponent > 0 {
            text += String(format: "%@:", hourComponent < 10 ? "0" + String(hourComponent) : String(hourComponent))
        }
        text += String(format: "%@:", minuteComponent < 10 ? "0" + String(minuteComponent) : String(minuteComponent))
        if hourComponent > 0 || includeMillisecond == false {
            text += String(format: "%@", secondComponent < 10 ? "0" + String(secondComponent) : String(secondComponent))
        } else {
            text += String(format: "%@.", secondComponent < 10 ? "0" + String(secondComponent) : String(secondComponent))
            text += String(milisecondComponent)
        }
        return text
    }
    
    public func spoken() -> String {
        var text = ""
        if dayComponent > 0 {
            text += " \(dayComponent) day\(dayComponent == 1 ? "" : "s")"
        }
        if hourComponent > 0 {
            text += " \(hourComponent) hour\(hourComponent == 1 ? "" : "s")"
        }
        if minuteComponent > 0 {
            text += " \(minuteComponent) minute\(minuteComponent == 1 ? "" : "s")"
        }
        if secondComponent > 0 {
            text += " \(secondComponent) second\(secondComponent == 1 ? "" : "s")"
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
        } else {
            return "Just now"
        }
        
    }
    
}

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

extension Array {
    var randomItem: Iterator.Element? {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[safe: index]
    }
}

extension Date {
    var month: Int? {
        let dateComponents = Calendar.current.dateComponents([.month], from: self)
        return dateComponents.month
    }
    var year: Int? {
        let dateComponents = Calendar.current.dateComponents([.year], from: self)
        return dateComponents.year
    }
    func dateWithoutTime() -> Date {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: dateComponents) ?? self
    }
    func isSameDay(as otherDate: Date) -> Bool {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let otherDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: otherDate)
        return (dateComponents.year == otherDateComponents.year) && (dateComponents.month == otherDateComponents.month) && (dateComponents.day == otherDateComponents.day)
    }
}

extension CLLocationSpeed {
    
    var color: UIColor {
        if self > Utils.metersPerSecond(unitsPerHour: Settings.speedRateFast) {
            return Settings.theme.greenColor
        } else if self > Utils.metersPerSecond(unitsPerHour: Settings.speedRateMedium) {
            return Settings.theme.yellowColor
        } else if self > Utils.metersPerSecond(unitsPerHour: Settings.speedRateSlow) {
            return Settings.theme.orangeColor
        } else {
            return Settings.theme.redColor
        }
    }
    
}

extension URL {
    
    var queryParameters: [String: String] {
        var queryParameters: [String: String] = [:]
        for queryParameter in query?.components(separatedBy: "&") ?? [] {
            let keyVal = queryParameter.components(separatedBy: "=")
            if keyVal.count == 2 {
                queryParameters[keyVal.first!] = keyVal.last!
            }
        }
        return queryParameters
    }
    
}

extension UIColor {
    
    var rgb: (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (red:fRed, green:fGreen, blue:fBlue, alpha:fAlpha)
        } else {
            return nil
        }
    }
    
    convenience init(hex: String) {
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        let a: CGFloat = 1
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = hex.substring(from: start)
            if hexColor.characters.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt32 = 0
                if scanner.scanHexInt32(&hexNumber) {
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255
                }
            }
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init?(startingColor: UIColor, endingColor: UIColor, percentage: CGFloat) {
        guard let startingRGB = startingColor.rgb, let endingRGB = endingColor.rgb else {
            return nil
        }
        let red = (1.0-percentage)*startingRGB.red + percentage*endingRGB.red
        let green = (1.0-percentage)*startingRGB.green + percentage*endingRGB.green
        let blue = (1.0-percentage)*startingRGB.blue + percentage*endingRGB.blue
        let alpha = (1.0-percentage)*startingRGB.alpha + percentage*endingRGB.alpha
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
