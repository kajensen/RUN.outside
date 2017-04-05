//
//  Weather.swift
//  RUN
//
//  Created by Kurt Jensen on 4/5/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

struct Weather {
    var temperatureInKelvin: Double
    var description: String?
    var id: String?
    
    var iconText: String? {
        guard let id = id else {
            return nil
        }
        let stripped = id.replacingOccurrences(of: "-d", with: "").replacingOccurrences(of: "-n", with: "")
        print(id, stripped)
        switch stripped {
        case "200":
            return String(format: "%C", 0xEB28)
        case "201":
            return String(format: "%C", 0xEB29)
        case "210":
            return String(format: "%C", 0xEB2A)
        case "211":
            return String(format: "%C", 0xEB33)
        case "212":
            return String(format: "%C", 0xEB34)
        case "221":
            return String(format: "%C", 0xEB3D)
        case "230":
            return String(format: "%C", 0xEB46)
        case "231":
            return String(format: "%C", 0xEB47)
        case "232":
            return String(format: "%C", 0xEB48)
            //
        case "300":
            return String(format: "%C", 0xEB8C)
        case "301":
            return String(format: "%C", 0xEB8D)
        case "302":
            return String(format: "%C", 0xEB8E)
        case "310":
            return String(format: "%C", 0xEB96)
        case "311":
            return String(format: "%C", 0xEB97)
        case "312":
            return String(format: "%C", 0xEB98)
        case "313":
            return String(format: "%C", 0xEB99)
        case "314":
            return String(format: "%C", 0xEB9A)
        case "321":
            return String(format: "%C", 0xEBA1)
        case "500":
            return String(format: "%C", 0xEC54)
        case "501":
            return String(format: "%C", 0xEC55)
        case "502":
            return String(format: "%C", 0xEC56)
        case "503":
            return String(format: "%C", 0xEC57)
        case "504":
            return String(format: "%C", 0xEC58)
        case "511":
            return String(format: "%C", 0xEC5F)
        case "520":
            return String(format: "%C", 0xEC68)
        case "521":
            return String(format: "%C", 0xEC55)
        case "522":
            return String(format: "%C", 0xEC6A)
        case "531":
            return String(format: "%C", 0xEC73)
            //
        case "600":
            return String(format: "%C", 0xECB8)
        case "601":
            return String(format: "%C", 0xECB9)
        case "602":
            return String(format: "%C", 0xECBA)
        case "611":
            return String(format: "%C", 0xECC3)
        case "612":
            return String(format: "%C", 0xECC4)
        case "615":
            return String(format: "%C", 0xECC7)
        case "616":
            return String(format: "%C", 0xECC8)
        case "620":
            return String(format: "%C", 0xECCC)
        case "621":
            return String(format: "%C", 0xECCD)
        case "622":
            return String(format: "%C", 0xECCE)
                //
        case "701":
            return String(format: "%C", 0xED1D)
        case "711":
            return String(format: "%C", 0xED27)
        case "721":
            return String(format: "%C", 0xED31)
        case "731":
            return String(format: "%C", 0xED3B)
        case "741":
            return String(format: "%C", 0xED45)
        case "751":
            return String(format: "%C", 0xED4F)
        case "761":
            return String(format: "%C", 0xED59)
        case "762":
            return String(format: "%C", 0xED5A)
        case "771":
            return String(format: "%C", 0xEED63)
        case "781":
            return String(format: "%C", 0xED6D)
            /*   Clouds - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    */
            
            /*  sky is clear  */  /*  Calm  */
        case "800", "951":
            if id.contains("-n") {
                return String(format: "%C", 0xF168)
            } else {
                return String(format: "%C", 0xED80)
            }
            /*  few clouds   */
        case "801":
            if id.contains("-n") {
                return String(format: "%C", 0xF169)
            } else {
                return String(format: "%C", 0xED81)
            }
            /* scattered clouds */
        case "802", "802-d":
            if id.contains("-n") {
                return String(format: "%C", 0xF16A)
            } else {
                return String(format: "%C", 0xED82)
            }
            /* broken clouds  */
        case "803":
            return String(format: "%C", 0xED83)
            /* overcast clouds  */
        case "804":
            return String(format: "%C", 0xED84)
            /*   Extreme - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    */
            
            /* tornado  */
        case "900":
            return String(format: "%C", 0xEDE4)
            /*  tropical storm  */
        case "901":
            return String(format: "%C", 0xEDE5)
            /* hurricane */
        case "902":
            return String(format: "%C", 0xEDE6)
            /* cold */
        case "903":
            return String(format: "%C", 0xEDE7)
            /* hot */
        case "904":
            return String(format: "%C", 0xEDE8)
            /* windy */
        case "905":
            return String(format: "%C", 0xEDE9)
            /* hail */
        case "906":
            return String(format: "%C", 0xEDEA)
            /*   Additional - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    */
            
            /* Setting */
        case "950":
            return String(format: "%C", 0xEE16)
            /*  Light breeze  */
        case "952":
            return String(format: "%C", 0xEE18)
            /*  Gentle Breeze  */
        case "953":
            return String(format: "%C", 0xEE19)
            /*  Moderate breeze  */
        case "954":
            return String(format: "%C", 0xEE1A)
            /* Fresh Breeze  */
        case "955":
            return String(format: "%C", 0xEE1B)
            /* Strong  Breeze  */
        case "956":
            return String(format: "%C", 0xEE1C)
            /* High wind, near gale  */
        case "957":
            return String(format: "%C", 0xEE1D)
            /* Gale */
        case "958":
            return String(format: "%C", 0xEE1E)
            /*  Severe Gale  */
        case "959":
            return String(format: "%C", 0xEE1F)
            /* Storm */
        case "960":
            return String(format: "%C", 0xEE20)
            /*  Violent Storm  */
        case "961":
            return String(format: "%C", 0xEE21)
            /* Hurricane */
        case "961":
            return String(format: "%C", 0xEE22)
        default:
            return nil
        }
    }
    
}
