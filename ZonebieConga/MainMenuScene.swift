//
//  MainMenuScene.swift
//  ZonebieConga
//
//  Created by shuaiqi sun on 2/13/16.
//  Copyright © 2016 shuaiqi sun. All rights reserved.
//

import SpriteKit
import Foundation

class MainMenuScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(background)
        
        let tapToStartLabel = SKLabelNode(text: "点击屏幕开始游戏")
        tapToStartLabel.fontName = "Pingfang-bold"
        tapToStartLabel.fontColor = .whiteColor()
        tapToStartLabel.fontSize = 100
        tapToStartLabel.position = CGPoint(x: size.width / 2 + 20, y: size.height / 5)
        tapToStartLabel.verticalAlignmentMode = .Baseline
        tapToStartLabel.horizontalAlignmentMode = .Center
        tapToStartLabel.zPosition = 100
        addChild(tapToStartLabel)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let mainScene = GameScene(size: self.size)
        mainScene.scaleMode = self.scaleMode
        self.view?.presentScene(mainScene, transition: SKTransition.doorwayWithDuration(1.5))
    }
}
