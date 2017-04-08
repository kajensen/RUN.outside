//
//  FootMarker.swift
//  RUN
//
//  Created by Kurt Jensen on 4/8/17.
//  Copyright © 2017 Arbor Apps. All rights reserved.
//

import GoogleMaps

class FootMarker: GMSMarker {
    
    override init() {
        super.init()
        let icon = UIImage(named: "icon_foot")?.withRenderingMode(.alwaysTemplate)
        let iconView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        iconView.tintColor = UIColor.white
        iconView.image = icon
        iconView.contentMode = .scaleAspectFit
        iconView.layer.borderWidth = 2
        iconView.layer.borderColor = UIColor.white.cgColor
        iconView.layer.cornerRadius = 10
        self.iconView = iconView
    }

}
