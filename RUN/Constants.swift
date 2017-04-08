//
//  Constants.swift
//  RUN
//
//  Created by Kurt Jensen on 3/23/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import UIKit

class Constants {
    
    static let googleMapsApiKey = "AIzaSyAE0_wLGmYZwsMqG7nF0VfCfmnXVU7oN1I"
    static let openWeatherApiKey = "36db18e14455b23d4c6db032972f0f9e"
    
    static let email = "arborapps+run@gmail.com"
    static let appGroup = "group.io.arborapps.RUN"
    static let redirectURL = "http://10.0.0.180:9999/run/auth/"//"http://arborapps.io/run/auth"
    
    class MapMyRun {
        
        static let apiKey = "ac2gucaz5w6248q2nbgmsz2rvczffvts"
        static let apiSecret = "73mgfNvK5h7QxFxw6VxwGM5AearmuR2TrQpupPQJa4H"
        static let apiURL = "https://api.ua.com/v7.1"
        
        static var oauthURL: URL? {
            guard let redirectURL = "\(Constants.redirectURL)mapmyrun".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
            }
            let responseType = "code"
            let url = "https://www.mapmyfitness.com/v7.1/oauth2/authorize/?client_id=\(apiKey)&response_type=\(responseType)&redirect_uri=\(redirectURL)"
            return URL(string: url)
        }
        
    }

}
