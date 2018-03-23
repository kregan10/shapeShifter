//
//  BopItButton.swift
//  BapIt
//
//  Created by Kerry Regan on 2018-03-14.
//  Copyright © 2018 Kerry Regan. All rights reserved.
//

import Foundation
import SpriteKit


class BackgroundShape : SKShapeNode {
   
    let backgroundLineWidth = CGFloat(3.0)
    let backgroundGlowWidth = CGFloat(2.0)

    override init() {
        super.init()
        self.glowWidth = backgroundGlowWidth
        self.lineWidth = backgroundLineWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}


