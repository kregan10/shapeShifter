//
//  BopItButton.swift
//  BapIt
//
//  Created by Kerry Regan on 2018-03-14.
//  Copyright © 2018 Kerry Regan. All rights reserved.
//

import Foundation
import SpriteKit


class Ship : SKShapeNode {
    
    let tronBlue = UIColor(red: (24.0/255), green: (202.0/255), blue: (230/255), alpha: 1.0)
    let shipGlowWidth = CGFloat(3.0)
    var kShipName = "ship"
    var kShipSize = CGSize(width: 30, height: 16)
    var shipHealth = 100.0
    var kKeyName = "key"
    

    override init() {
        super.init()
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: 30,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        self.lineWidth = 5
        self.fillColor = .black
        self.strokeColor = tronBlue
        self.glowWidth = shipGlowWidth
        
        self.name = kShipName

    }
    
    func adjustShipHealth(by healthAdjustment: Float) {
        self.shipHealth = max(self.shipHealth + Double(healthAdjustment), 0)
    }
    
    func getShipHealth() -> Double {
        return self.shipHealth
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}

