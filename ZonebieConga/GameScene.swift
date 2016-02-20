//
//  GameScene.swift
//  ZonebieConga
//
//  Created by shuaiqi sun on 2/1/16.
//  Copyright (c) 2016 shuaiqi sun. All rights reserved.
//

import SpriteKit

class GameScene : SKScene {
    
    let cameraNode = SKCameraNode()
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect : CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    let catCollisionSound : SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var zombieIsInvincible : Bool = false
    let catMovePointsPerSec: CGFloat = 480.0
    var lives = 5
    var gameOver = false
    let cameraMovePointPersec: CGFloat = 200.0
    var cameraRect : CGRect {
        return CGRect(
            x: getCameraPosition().x - size.width / 2 + (size.width - playableRect.width) / 2,
            y: getCameraPosition().y - size.height / 2 + (size.height - playableRect.height) / 2,
            width: playableRect.width,
            height: playableRect.height)
    }
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    let catsLabel = SKLabelNode(fontNamed: "Glimstick")
    
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        
        // MARK: - Adding the Background
        playBackgroundMusic("backgroundMusic.mp3")
        for i in 0...1{
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            // is the same as anchoring its lower left corner and then position it on screen
            /*background.anchorPoint = CGPointZero // defult is CGPoint(x: 0.5, y:0.5)
            background.position = CGPointZero*/
            //        background.zRotation = CGFloat( M_PI / 8 ) // 这里一个PI是180°
            background.zPosition = -1
            addChild(background)
        
        }
        
        // MARK: - Adding Zomebie
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        
        runAction(
            SKAction.repeatActionForever(
                SKAction.sequence(
                    [SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)]
                )
            )
        )
        
        runAction(
            SKAction.repeatActionForever(
                SKAction.sequence(
                    [SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)]
                )
            )
        )
        addChild(zombie)
//        debugDrawPlayableArea()
        addChild(cameraNode)
        camera = cameraNode
        setCameraPosition(CGPoint(x: size.width / 2, y: size.height / 2))
        livesLabel.text = "Lives: X"
        livesLabel.fontColor = .blackColor()
        livesLabel.fontSize = 100
        livesLabel.zPosition = 100
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount() / 2
        )
        livesLabel.horizontalAlignmentMode = .Left
        livesLabel.verticalAlignmentMode = .Bottom
        cameraNode.addChild(livesLabel)
        
        catsLabel.text = "Cats: X"
        catsLabel.fontColor = .blackColor()
        catsLabel.fontSize = 100
        catsLabel.zPosition = 100
        catsLabel.position = CGPoint(
            x: playableRect.size.width / 2 - CGFloat(20),
            y: -playableRect.size.height / 2 + CGFloat(20) + overlapAmount() / 2
        )
        catsLabel.horizontalAlignmentMode = .Right
        catsLabel.verticalAlignmentMode = .Bottom
        cameraNode.addChild(catsLabel)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        /*if let lastTouchLocation = lastTouchLocation {
            let diff : CGPoint = lastTouchLocation - zombie.position
            
            if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
                zombie.position = lastTouchLocation
                velocity = CGPointZero
                stopZombieAnimation()
            }else{*/
                moveSprite(sprite: zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            /*}
        }*/
        boudsCheckZombie()
        moveTrain()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You Lose!")
            backgroundMusicPlayer.stop()
            let gameOVerScene = GameOverScene(size: size, won: false)
            gameOVerScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOVerScene, transition: reveal)
        }
        moveCamera()
    }

    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveSprite(sprite sprite:SKSpriteNode, velocity:CGPoint) {
        
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity  = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func boudsCheckZombie() {
        let bottomLeft = CGPoint(x: CGRectGetMinX(cameraRect), y: CGRectGetMinY(cameraRect))
        let topRight = CGPoint(x: CGRectGetMaxX(cameraRect), y: CGRectGetMaxY(cameraRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: CGRectGetMaxX(cameraRect) + enemy.size.width / 2, y: CGFloat.random(min: CGRectGetMinY(cameraRect) + enemy.size.height / 2, max: CGRectGetMaxY(cameraRect) - enemy.size.height / 2))
        enemy.zPosition = 49
        addChild(enemy)
        
        let actionMove = SKAction.moveByX(-size.width - enemy.size.width * 2, y: 0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
        enemy.name = "enemy"
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(cameraRect), max: CGRectGetMaxX(cameraRect)),
            y: CGFloat.random(min: CGRectGetMinY(cameraRect), max: CGRectGetMaxY(cameraRect)))
        cat.zPosition = 50
        cat.setScale(0)
        addChild(cat)
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        let leftWiggle = SKAction.rotateByAngle(π / 8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
        cat.name = "cat"
    }
    func zombieHitCat(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        
        let turnGreenAction = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        cat.runAction(turnGreenAction)
        runAction(catCollisionSound)
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
        zombieIsInvincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            // 闪动持续时长 / 闪动次数 = 单次闪动耗时
            let remainder = Double(elapsedTime) % slice
            // 逝去时间 % 单次闪动耗时 = 余数
            node.hidden = remainder > slice / 2
            // 如果 余数 > 单次闪动耗时 / 2 则 人物隐藏
        }
        let group = SKAction.group([enemyCollisionSound, blinkAction])
        let setHiddenFalse = SKAction.runBlock { () -> Void in
            self.zombie.hidden = false
            self.zombieIsInvincible = false
        }
        let actionSequence = SKAction.sequence([group,setHiddenFalse])
        zombie.runAction(actionSequence)
        
        loseCats()
        lives--
    }
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { ( node, _) -> Void in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        hitCats.forEach { (cat) -> () in
            zombieHitCat(cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        if zombieIsInvincible == false {
            enumerateChildNodesWithName("enemy") { (node, _) -> Void in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
            hitEnemies.forEach { (enemy) -> () in
                zombieHitEnemy(enemy)
            }
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        
        enumerateChildNodesWithName("train") { (node, _) -> Void in
            trainCount++
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePersec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePersec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(CGVector(dx: amountToMove.x, dy: amountToMove.y), duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
            
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You Win!")
            backgroundMusicPlayer.stop()
            let gameOVerScene = GameOverScene(size: size, won: true)
            gameOVerScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOVerScene, transition: reveal)
        }
        livesLabel.text = "Lives: \(lives)"
        catsLabel.text = "Cats: \(trainCount)"
    }
    
    func loseCats() {
        var loseCount = 0
        enumerateChildNodesWithName("train") { (node, stop) -> Void in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            node.runAction(
                SKAction.sequence([
                    SKAction.group(
                        [SKAction.rotateByAngle(π * 4, duration: 1.0),
                            SKAction.moveTo(randomSpot, duration: 1.0),
                            SKAction.scaleTo(0, duration: 1.0)]
                    ),
                    SKAction.removeFromParent()]
            ))
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    
    func overlapAmount() -> CGFloat {
        guard let view = self.view else{
            return 0
        }
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverLap = scaledHeight - view.bounds.size.height
        return scaledOverLap / scale
    }
    
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount() / 2)
    }
    
    func setCameraPosition(position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount() / 2)
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPointZero
        background1.position = CGPointZero
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPointZero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointPersec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        enumerateChildNodesWithName("background") { (node, _) -> Void in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width * 2, y: background.position.y)
            }
        }
    }
   
    func SwiftLog(items: Any, filename: String = __FILE__, line: Int = __LINE__, funcname: String = __FUNCTION__) {
        print("\(filename.componentsSeparatedByString("/").last!)(\(line)) \(funcname):\r\(items)\n")
    }
}