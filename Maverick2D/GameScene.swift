//
//  GameScene.swift
//  Maverick2D
//
//  Created by Alex DeMars on 12/19/16.
//  Copyright © 2016 Alex DeMars. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var tileMap = SKTileMapNode()
  
  var player = Player(x: 0, y: 0, angle: 0, speed: 7, plane: Plane(type: "spitfire"))
  var lastUpdatedTime: TimeInterval = 0.0
  
  var isTurningRight = false
  var isTurningLeft = false
  var turningAbility: Double = 2
  
  let map: SKSpriteNode = {
    let node = SKSpriteNode(imageNamed: "map")
    node.name = "map"
    node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    node.position = CGPoint(x: 0, y: 0)
    node.size = CGSize(width: 4096, height: 4096)
    node.physicsBody?.affectedByGravity = false
    node.zPosition = 1
    return node
  }()
  
  let analogStick: AnalogStick = {
    let stick = AnalogStick(position: CGPoint(x: 0, y: -512))
    stick.name = "analogStick"
    return stick
  }()
  
  override func didMove(to view: SKView) {
    createTileMap()
    createPlane()
    createAnalogStick()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      if touch.location(in: analogStick).x < 0 {
        isTurningRight = false
        isTurningLeft = true
        turningAbility = -0.03 * Double(touch.location(in: analogStick).x)
      } else if touch.location(in: analogStick).x > 0 {
        isTurningLeft = false
        isTurningRight = true
        turningAbility = 0.03 * Double(touch.location(in: analogStick).x)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    turningAbility = 3
    isTurningLeft = false
    isTurningRight = false
  }
  
  override func update(_ currentTime: TimeInterval) {
    if lastUpdatedTime == 0.0 {
      lastUpdatedTime = currentTime
    }
    
    var accumulatedFrames = round((currentTime - lastUpdatedTime) * 60)
    
    lastUpdatedTime = currentTime
    
    while accumulatedFrames > 0 {
      updateWorld()
      accumulatedFrames -= 1
    }
  }
  
  func updateWorld() {
    movePlane()
  }
  
  func createAnalogStick() {
    addChild(analogStick)
  }
  
  func createPlane() {
    player.plane.position = CGPoint(x: 0, y: 0)
    self.addChild(player.plane)
  }
  
  func createTileMap() {
    let waterTile = SKTileDefinition(texture: SKTexture(imageNamed: "map-tile-1"))
    let waterTileGroup = SKTileGroup(tileDefinition: waterTile)
    
    var tileDefinitions = [SKTileDefinition]()
    
    var i = 34
    while i >= 0 {
      tileDefinitions.append(SKTileDefinition(texture: SKTexture(imageNamed: "land-tile-\(i)")))
      print(tileDefinitions)
      i -= 1
    }
    
    let landTileGroupRule = SKTileGroupRule(adjacency: .adjacencyAll, tileDefinitions: tileDefinitions)
    let landTileGroup = SKTileGroup(rules: [landTileGroupRule])
    
    let tileSet = SKTileSet(tileGroups: [waterTileGroup, landTileGroup], tileSetType: .grid)
    
    tileMap = SKTileMapNode(tileSet: tileSet, columns: 8, rows: 8, tileSize: waterTile.size)
    tileMap.fill(with: waterTileGroup)
    
//    let columns = [7, 6, 7, 6, 5, 4, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2, 1, 6, 5, 2, 1, 0, 6, 5, 4, 3, 1, 0, 4, 3, 2, 2, 2]
//    let rows    = [0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 7]
    
//    for (index, tile) in tileDefinitions.enumerated() {
//      tileMap.setTileGroup(landTileGroup, andTileDefinition: tile, forColumn: columns[index], row: rows[index])
//    }
    
    self.addChild(tileMap)
  }
  
  func movePlane() {
    let dx = player.x + CGFloat(player.speed * sin(M_PI / 180 * player.angle))
    let dy = player.y - CGFloat(player.speed * cos(M_PI / 180 * player.angle))
    
    if dx < 2048 && dx > -2048 {
      player.x = dx
    }
    
    if dy < 2048 && dy > -2048 {
      player.y = dy
    }
    
    if isTurningLeft {
      player.angle += turningAbility
    } else if isTurningRight {
      player.angle -= turningAbility
    }
    
    tileMap.position.x = player.x
    tileMap.position.y = player.y
    
    player.plane.zRotation = CGFloat(player.angle * M_PI / 180)
  }
}
