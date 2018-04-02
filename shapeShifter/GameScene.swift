import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Private GameScene Properties
    let motionManager = CMMotionManager()
    var contentCreated = false
    
    private var ship = SKNode()
    private var key = Key()
    var backgroundTriangle = SKShapeNode()
    var backgroundSquare = SKShapeNode()
    var backgroundOctagon = SKShapeNode()
    
    // UI colors and dimensions of backgroud shapes
   
    let shipGlowWidth = CGFloat(3.0)
    let backgroundShapeWidths = CGFloat(165.0)
    let tronBlue = UIColor(red: (24.0/255), green: (202.0/255), blue: (230/255), alpha: 1.0)

    var contactQueue = [SKPhysicsContact]()

    private var isKeyOnScreen = false
    private var hasRetrievedKey = false

    // Time per move will be used for generating a random Key
    var timeOfLastKeySpawn: CFTimeInterval = 0.0
    let timePerKeySpawn: CFTimeInterval = 5.0
    
    // Time constants for detecting and calculating user hovering over shapes
    let timePerHover: CFTimeInterval = 1.0
    var timeOfHoverInit: CFTimeInterval = 0.0
    
    // Users score and ship health
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    
    var gameEnding: Bool = false
    
    var hasTexturesBeenSet = false
    
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    let kKeyName = "key"
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    // Scene Setup and Content Creation
    override func didMove(to view: SKView) {
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            motionManager.startAccelerometerUpdates()
            physicsWorld.contactDelegate = self
            print("didMove")
            self.hasRetrievedKey = false
        }
    }
    
    func createContent() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        setupShip()
        setupHud()
        setupBackgroundShapes()

        // black space color
        self.backgroundColor = SKColor.black
    }
    
    func setupShip() {
        ship = makeShip()
        ship.zPosition = 10
        ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        
        addChild(ship)
    }
    
    func setupBackgroundShapes() {
        backgroundTriangle = makeTopTriangle()
        backgroundTriangle.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 5.0))
        
        backgroundSquare = makeMidSquare()
        backgroundSquare.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 3.0))
        
        backgroundOctagon = makeBotOctogon()
        backgroundOctagon.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 1.0))
        
        addChild(backgroundTriangle)
        addChild(backgroundSquare)
        addChild(backgroundOctagon)
    }
    
    
    func spawnRandomKey(forUpdate currentTime: CFTimeInterval) {

        print("spawnRandomKey currentTime " + String(describing: currentTime))
        print("spawnRandomKey timeOfLastKeySpawn " + String(describing: timeOfLastKeySpawn) )
        print("spawnRandomKey timePerKeySpawn " + String(describing: timePerKeySpawn) )
        print("spawnRandomKey isKeyOnScreen " + String(describing: isKeyOnScreen) )
        // If 5 seconds hasn't passed, or if there is a key already on the screen,
        // we wont spawn another one
        if (currentTime - timeOfLastKeySpawn < timePerKeySpawn)  || isKeyOnScreen {
            return
        }
        
        if !isKeyOnScreen {
            key = Key()
            key.setKey()
            let randomY = CGFloat(arc4random_uniform(UInt32(size.height - 20)) + 20)
            let randomX = CGFloat(arc4random_uniform(UInt32(size.height - 20)) + 20)
            key.position.x = randomX
            key.position.y = randomY
            key.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 3.0))
            key.zPosition = 10
            addChild(key)
            isKeyOnScreen = true
            self.timeOfLastKeySpawn = currentTime
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }
    
    
    
    func adjustScore(by points: Int) {
        score += points
        if let score = childNode(withName: kScoreHudName) as? SKLabelNode {
            score.text = String(format: "Score: %04u", self.score)
        }
    }
    
    func adjustShipHealth(by healthAdjustment: Float) {
        if (shipHealth + healthAdjustment) > 1.0 || shipHealth > 1.0 {
            shipHealth = 1.0
        } else {
            shipHealth = max(shipHealth + healthAdjustment, 0)
        }
        
        if let health = childNode(withName: kHealthHudName) as? SKLabelNode {
            health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        }
    }
    
    func makeTopTriangle() -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 60.0))
        path.addLine(to: CGPoint(x: backgroundShapeWidths / 2, y: -53.0))
        path.addLine(to: CGPoint(x: -backgroundShapeWidths / 2, y: -53.0))
        path.addLine(to: CGPoint(x: 0.0, y: 60.0))
        let triangle = BackgroundShape(path: path.cgPath)
        triangle.strokeColor = tronBlue
        triangle.name = "triangle"
        triangle.fillColor = .black
        return triangle
    }
    
    func makeMidSquare() -> SKShapeNode {
        
        let size = CGSize(width: backgroundShapeWidths, height: backgroundShapeWidths)
        let square = BackgroundShape(rectOf: size,
                                          cornerRadius: 3)
        square.strokeColor = tronBlue
        square.name = "square"
        square.fillColor = .black
        return square
        
    }
    
    func makeBotOctogon() -> SKShapeNode {
        
        let path = polygonPath(x: 0.0, y: 0.0, radius: backgroundShapeWidths / 2, sides: 8, offset: 0.0)
        let octagon = BackgroundShape(path: path)
        octagon.strokeColor = tronBlue
        octagon.name = "octagon"
        octagon.fillColor = .black
        return octagon
        
    }
    
    func makeShip() -> SKNode {
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: 30,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        let ship = SKShapeNode(path: path)
        ship.lineWidth = 5
        ship.fillColor = .black
        ship.strokeColor = tronBlue
        ship.glowWidth = shipGlowWidth
        
        ship.name = kShipName
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.restitution = 0.5
        ship.physicsBody!.mass = 0.02
        ship.physicsBody!.collisionBitMask = 0b0001

        return ship
    }
    
    func setupHud() {
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.green
        scoreLabel.text = String(format: "Score: %04u", 0)
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (40 + scoreLabel.frame.size.height/2)
        )
        
        addChild(scoreLabel)
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        healthLabel.fontColor = SKColor.red
        healthLabel.text = String(format: "Health: %.1f%%", 100.0)
        healthLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (80 + healthLabel.frame.size.height/2)
        )
        
        addChild(healthLabel)
    }
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        if let ship = childNode(withName: kShipName) as? SKShapeNode {
            if let data = motionManager.accelerometerData {
                if fabs(data.acceleration.x) > 0.1 {
                    print("Acceleration: \(data.acceleration.x)")
                    ship.physicsBody!.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
                }
                if fabs(data.acceleration.y) > 0.1 {
                    print("Acceleration: \(data.acceleration.x)")
                    ship.physicsBody!.applyForce(CGVector(dx: 0, dy: 40 * CGFloat(data.acceleration.y)))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver() {
            endGame()
        }
        processUserGettingKey()
        processUserMotion(forUpdate: currentTime)
        spawnRandomKey(forUpdate: currentTime)
        processUserOverBackgroundShapes(forUpdate: currentTime)
        //updateGameTime(currentTime)
    }
    
    // Need to check if the user has been over a shape for more thn 0.5 seconds
    // Constantly bring health down when user is not over the shape
    //
    func processUserOverBackgroundShapes(forUpdate currentTime: CFTimeInterval) {
        
        if isKeyOnScreen {
            self.hasRetrievedKey = false
            self.adjustShipHealth(by: -0.001)
            return
        }
        
        let pos = ship.position
        if ship.intersects(backgroundTriangle) {
            // If the current shape matches what the key requests then increase health and score
            // If the current shape does not match the background, then reduce the ship health
            if key.getKey() == "triangle"  && !hasRetrievedKey {

                self.backgroundTriangle.fillColor = UIColor.green
                self.adjustShipHealth(by: 0.25)
                self.adjustScore(by: 50)
                print("Intersecting triangle")
                hasRetrievedKey = true
                ship.removeFromParent()
                ship = self.makeShip()
                self.addChild(ship)
                ship.position = pos
                ship.zPosition = 10
                
            }
            
            if key.getKey() != "triangle" {
                self.backgroundTriangle.fillColor = UIColor.red
                self.adjustShipHealth(by: -0.005)

            }
        } else {
            // If the user is not on the triangle, change it back to black
            self.backgroundTriangle.fillColor = UIColor.black
        }
        
        if ship.intersects(backgroundSquare) && !hasRetrievedKey{
            if key.getKey() == "square" {

                self.backgroundSquare.fillColor = UIColor.green
                self.adjustShipHealth(by: 0.25)
                self.adjustScore(by: 50)
                print("Intersecting square")
                hasRetrievedKey = true
                ship.removeFromParent()
                ship = self.makeShip()
                self.addChild(ship)
                ship.position = pos
                ship.zPosition = 10            }
            
            if key.getKey() != "square" {
                self.backgroundSquare.fillColor = UIColor.red
                self.adjustShipHealth(by: -0.005)
            }
        } else {
            self.backgroundSquare.fillColor = UIColor.black
        }
        
        if ship.intersects(backgroundOctagon) && !hasRetrievedKey{
            if key.getKey() == "octagon" {
                self.backgroundOctagon.fillColor = UIColor.green
                self.adjustShipHealth(by: 0.25)
                self.adjustScore(by: 50)
                print("Intersecting octagon")
                hasRetrievedKey = true
                ship.removeFromParent()
                ship = self.makeShip()
                self.addChild(ship)
                ship.position = pos
                ship.zPosition = 10            }
            
            if key.getKey() != "octagon" {
                self.backgroundOctagon.fillColor = UIColor.red
                self.adjustShipHealth(by: -0.005)
            }
        } else {
            self.backgroundOctagon.fillColor = UIColor.black
        }
    }
    
    func updateGameKeySpawnTime(_ currentTime: TimeInterval) {
        self.timeOfLastKeySpawn = currentTime
    }
    
    func processUserGettingKey() {
        //checking if ship is in contact with key
        if let contacted = self.ship.physicsBody?.allContactedBodies() {
            if contacted.contains((self.key.physicsBody)!) {
                // increment score
                adjustScore(by: 10)
                
                // checking if the child node with the name key is in contact
                if let currKey = self.childNode(withName: "key") as? SKShapeNode {
                    
                    if let currShip = self.childNode(withName: "ship") as? SKShapeNode {
                        print("Removing key")
                        let pos = currShip.position
                        switch key.shapeKey[key.currShape] {
                            case "triangle":
                                print("triangle")
                                ship.removeFromParent()
                                ship = key.morphToTriangle()
                                self.addChild(ship)
                                ship.position = pos
                                ship.zPosition = 10
                            case "square":
                                print("square")
                                ship.removeFromParent()
                                ship = key.morphToSquare()
                                self.addChild(ship)
                                ship.position = pos
                                ship.zPosition = 10
                            case "octagon":
                                print("octagon")
                                ship.removeFromParent()
                                ship = key.morphToOctagon()
                                self.addChild(ship)
                                ship.position = pos
                                ship.zPosition = 10
                            default:
                                print("No shape returned from key")
                        }
                        currKey.removeFromParent()
                        isKeyOnScreen = false
                    }
                }
            }
        }
    }
    
    func isGameOver() -> Bool {
        return self.shipHealth <= 0
    }
    
    func endGame() {
        if !gameEnding {
            gameEnding = true
            motionManager.stopAccelerometerUpdates()
            
            let gameOverScene: GameOverScene = GameOverScene(size: size)
            gameOverScene.userScore = self.score
            view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
    
    func polygonPointArray(sides:Int, x:CGFloat, y:CGFloat, radius:CGFloat, offset:CGFloat) -> [CGPoint] {
        let angle = (360/CGFloat(sides)).radians()
        let cx = x // x origin
        let cy = y // y origin
        let r = radius // radius of circle
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - offset.radians())
            let ypo = cy + r * sin(angle * CGFloat(i) - offset.radians())
            points.append(CGPoint(x: xpo, y: ypo))
            i = i + 1
        }
        return points
    }
    
    func polygonPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, offset: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let points = polygonPointArray(sides: sides,x: x,y: y,radius: radius, offset: offset)
        let cpg = points[0]
        path.move(to: cpg)

        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
    
    
}


// https://stackoverflow.com/questions/40362204/add-glowing-effect-to-an-skspritenode
extension SKSpriteNode {
    
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}


extension CGFloat {
    func radians() -> CGFloat {
        let b = CGFloat(Double.pi) * (self/180)
        return b
    }
}

extension SKShapeNode {
    
    // Ship's radius is 30.0
    func morphToTriangle() -> SKShapeNode {
        
        let tronBlue = UIColor(red: (24.0/255), green: (202.0/255), blue: (230/255), alpha: 1.0)
        let kShipSize = CGSize(width: 30, height: 16)
        let shipGlowWidth = CGFloat(3.0)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: 35.0))
        path.addLine(to: CGPoint(x: 40.0, y: 0.0))
        path.addLine(to: CGPoint(x: -40.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: 35.0))
        
        let triangle = SKShapeNode(path: path.cgPath)
        
        triangle.strokeColor = tronBlue
        triangle.name = "ship"
        triangle.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        triangle.physicsBody!.isDynamic = true
        triangle.physicsBody!.affectedByGravity = false
        triangle.physicsBody!.restitution = 0.5
        triangle.physicsBody!.mass = 0.02
        triangle.physicsBody!.collisionBitMask = 0b0001
        triangle.glowWidth = shipGlowWidth
        
        return triangle
    }
    
    func morphToSquare() -> SKShapeNode {
        
        let squareSize = CGSize(width: 50, height: 50)
        let shipGlowWidth = CGFloat(3.0)
        let square = SKShapeNode(rectOf: squareSize)
        let tronBlue = UIColor(red: (24.0/255), green: (202.0/255), blue: (230/255), alpha: 1.0)
        
        square.name = "ship"
        square.strokeColor = tronBlue
        square.physicsBody = SKPhysicsBody(rectangleOf: squareSize)
        square.physicsBody!.isDynamic = true
        square.physicsBody!.affectedByGravity = false
        square.physicsBody!.restitution = 0.5
        square.physicsBody!.mass = 0.02
        square.physicsBody!.collisionBitMask = 0b0001
        square.glowWidth = shipGlowWidth

        return square
    }
    
    func morphToOctagon() -> SKShapeNode {
        
        let tronBlue = UIColor(red: (24.0/255), green: (202.0/255), blue: (230/255), alpha: 1.0)
        let path = polygonPath(x: 0.0, y: 0.0, radius: 30, sides: 8, offset: 0.0)
        let octagon = SKShapeNode(path: path)
        let shipGlowWidth = CGFloat(3.0)

        octagon.strokeColor = tronBlue
        octagon.name = "ship"
        octagon.physicsBody = SKPhysicsBody(polygonFrom: path)
        octagon.physicsBody!.isDynamic = true
        octagon.physicsBody!.affectedByGravity = false
        octagon.physicsBody!.restitution = 0.5
        octagon.physicsBody!.mass = 0.02
        octagon.physicsBody!.collisionBitMask = 0b0001
        octagon.glowWidth = shipGlowWidth

        return octagon
        
    }
    
    func polygonPointArray(sides:Int, x:CGFloat, y:CGFloat, radius:CGFloat, offset:CGFloat) -> [CGPoint] {
        
        let angle = (360/CGFloat(sides)).radians()
        let cx = x // x origin
        let cy = y // y origin
        let r = radius // radius of circle
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - offset.radians())
            let ypo = cy + r * sin(angle * CGFloat(i) - offset.radians())
            points.append(CGPoint(x: xpo, y: ypo))
            i = i + 1
        }
        return points
    }
    
    func polygonPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, offset: CGFloat) -> CGPath {
        
        let path = CGMutablePath()
        let points = polygonPointArray(sides: sides,x: x,y: y,radius: radius, offset: offset)
        let cpg = points[0]
        path.move(to: cpg)
        
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
    
}


