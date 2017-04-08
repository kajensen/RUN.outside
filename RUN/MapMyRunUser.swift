//
//  MapMyRunUser.swift
//  RUN
//
//  Created by Kurt Jensen on 4/7/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class MapMyRunUser: Object {
    
    static var currentUser: MapMyRunUser? {
        guard let realm = try? Realm() else { return nil }
        let user = realm.objects(MapMyRunUser.self).first
        return user
    }
    
    dynamic var id: Int = 0
    dynamic var session: Session?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init?(json: JSON, session: Session) {
        let id = json["id"].intValue
        guard id > 0 else { return nil }
        self.init()
        self.id = id
        self.session = session
    }
    
}
