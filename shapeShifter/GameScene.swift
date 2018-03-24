import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Private GameScene Properties
    let motionManager = CMMotionManager()
    var contentCreated = false
    
    private var ship = SKNode()
//    private var shipTriangle = SKNode()
//    private var shipOctagon = SKNode()
//    private var shipSquare = SKNode()
//
    private var key = Key()
    
    // UI colors and dimensions of backgroud shapes
   
    let shipGlowWidth = CGFloat(3.0)
    let backgroundShapeWidths = CGFloat(165.0)
    let tronBlue = UIColor(red: (24.0/255), green: (202.0/255), blue: (230/255), alpha: 1.0)

    
    var contactQueue = [SKPhysicsContact]()

    private var isKeyOnScreen = false
    
    // Time per move will be used for generating a random Key
    var timeOfLastKeySpawn: CFTimeInterval = 0.0
    let timePerKeySpawn: CFTimeInterval = 5.0
    
    // Users score and ship health
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    var gameEnding: Bool = false

    
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    let kKeyName = "key"
    
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    override func didMove(to view: SKView) {
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            motionManager.startAccelerometerUpdates()
            physicsWorld.contactDelegate = self

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
        // 1
        ship = makeShip()
        
        // 2
        ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        
        addChild(ship)
    }
    
    func setupBackgroundShapes() {
        let topTriangle = makeTopTriangle()
        topTriangle.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 5.0))
        
        let midSquare = makeMidSquare()
        midSquare.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 3.0))
        
        let botOctogon = makeBotOctogon()
        botOctogon.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 1.0))
        
        addChild(topTriangle)
        addChild(midSquare)
        addChild(botOctogon)
    }
    
    
    func spawnRandomKey(forUpdate currentTime: CFTimeInterval) {
        // 1
        print("spawnRandomKey currentTime " + String(describing: currentTime))
        print("spawnRandomKey timeOfLastKeySpawn " + String(describing: timeOfLastKeySpawn) )
        print("spawnRandomKey timePerKeySpawn " + String(describing: timePerKeySpawn) )
        print("spawnRandomKey isKeyOnScreen " + String(describing: isKeyOnScreen) )
        // If 5 seconds hasn't passed, or if there is a key already on the screen,
        // we wont spawn another one
        if (currentTime - timeOfLastKeySpawn < timePerKeySpawn)  || isKeyOnScreen {
            return
        }
        
        key = Key()
        key.setKey()
        let randomY = CGFloat(arc4random_uniform(UInt32(size.height - 20)) + 20)
        let randomX = CGFloat(arc4random_uniform(UInt32(size.height - 20)) + 20)
        key.position.x = randomX
        key.position.y = randomY
        key.position = CGPoint(x: size.width / 2.0, y: ((size.height / 6.0) * 3.0))
        addChild(key)
        isKeyOnScreen = true
        self.timeOfLastKeySpawn = currentTime
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
        // 1
        shipHealth = max(shipHealth + healthAdjustment, 0)
        
        if let health = childNode(withName: kHealthHudName) as? SKLabelNode {
            health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        }
    }
    
    func makeTopTriangle() -> SKNode {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 60.0))
        path.addLine(to: CGPoint(x: backgroundShapeWidths / 2, y: -53.0))
        path.addLine(to: CGPoint(x: -backgroundShapeWidths / 2, y: -53.0))
        path.addLine(to: CGPoint(x: 0.0, y: 60.0))
        let triangle = BackgroundShape(path: path.cgPath)
        triangle.strokeColor = tronBlue
        triangle.name = "triangle"
        return triangle
    }
    
    func makeMidSquare() -> SKNode {
        
        let size = CGSize(width: backgroundShapeWidths, height: backgroundShapeWidths)
        let square = BackgroundShape(rectOf: size,
                                          cornerRadius: 3)
        square.strokeColor = tronBlue
        square.name = "square"
        return square
        
    }
    
    func makeBotOctogon() -> SKNode {
        
        let path = polygonPath(x: 0.0, y: 0.0, radius: backgroundShapeWidths / 2, sides: 8, offset: 0.0)
        let octagon = BackgroundShape(path: path)
        octagon.strokeColor = tronBlue
        octagon.name = "octagon"
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
                if fabs(data.acceleration.x) > 0.2 {
                    print("Acceleration: \(data.acceleration.x)")
                    ship.physicsBody!.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
                }
                if fabs(data.acceleration.y) > 0.2 {
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
        //updateGameTime(currentTime)
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
                            case "square":
                                print("square")
                                ship.removeFromParent()
                                ship = key.morphToSquare()
                                self.addChild(ship)
                                ship.position = pos
                            case "octagon":
                                print("octagon")
                                ship.removeFromParent()
                                ship = key.morphToOctagon()
                                self.addChild(ship)
                                ship.position = pos
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
        // 1
        if !gameEnding {
            gameEnding = true
            motionManager.stopAccelerometerUpdates()
            let gameOverScene: GameOverScene = GameOverScene(size: size)
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


