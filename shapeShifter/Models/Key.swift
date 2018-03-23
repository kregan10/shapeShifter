//
//  BopItButton.swift
//  BapIt
//
//  Created by Kerry Regan on 2018-03-14.
//  Copyright © 2018 Kerry Regan. All rights reserved.
//

import Foundation
import SpriteKit


class Key : SKShapeNode {
    
    private var defaultGlowWidth = 1.0
    let tronYellow = UIColor(red: (255/255), green: (230/255), blue: (77/255), alpha: 1.0)
    var shapeKey: [String] = ["triangle", "square", "octagon"]

    var currShape = 0
    let radius = 100
    
    override init() {
        super.init()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 20.0))
        path.addLine(to: CGPoint(x: 15.0, y: 0))
        path.addLine(to: CGPoint(x: 0.0, y: -20.0))
        path.addLine(to: CGPoint(x: -15.0, y: 0))
        path.addLine(to: CGPoint(x: 0.0, y: 20.0))
        
        self.path = path.cgPath
        self.lineWidth = 2.0
        self.strokeColor = tronYellow
        self.glowWidth = CGFloat(2.0)
        self.name = "key"
        self.isUserInteractionEnabled = false
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: path.cgPath)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody!.contactTestBitMask = 0b0010
        self.setKey()
    }
    
    func getKey() -> String {
        return self.shapeKey[currShape]
    }
    
    func setKey() {
        let diceRoll = Int(arc4random_uniform(3))
        switch diceRoll {
        case 0:
            self.currShape = 0
            break
        case 1:
            self.currShape = 1
            break
        case 2:
            self.currShape = 2
            break
        default:
            return
        }
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}
