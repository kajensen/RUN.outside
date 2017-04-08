//
//  Session.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift

import RealmSwift
import SwiftyJSON

class Session: Object {
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else {
            return false
        }
        return expirationDate.compare(Date()) == .orderedAscending
    }
    
    dynamic var expirationDate: Date?
    dynamic var refreshToken: String?
    dynamic var scope: String?
    dynamic var tokenType: String?
    dynamic var accessToken: String?
    
    convenience init(json: JSON) {
        self.init()
        refresh(json: json)
    }
    
    func refresh(json: JSON) {
        if let expiresIn = json["expires_in"].double {
            self.expirationDate = Date(timeIntervalSinceNow: expiresIn)
        }
        if let refreshToken = json["refresh_token"].string {
            self.refreshToken = refreshToken
        }
        if let scope = json["scope"].string {
            self.scope = scope
        }
        if let tokenType = json["token_type"].string {
            self.tokenType = tokenType
        }
        if let accessToken = json["access_token"].string {
            self.accessToken = accessToken
        }
    }
    
}

