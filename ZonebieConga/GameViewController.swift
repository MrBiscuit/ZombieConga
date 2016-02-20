//
//  GameViewController.swift
//  ZonebieConga
//
//  Created by shuaiqi sun on 2/1/16.
//  Copyright (c) 2016 shuaiqi sun. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenuScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
