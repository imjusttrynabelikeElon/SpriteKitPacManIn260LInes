import SpriteKit



var ghostSpeed = CGFloat(12)
var ghostDecisionPeriodSeconds = 0.1

class GhostNode : SKSpriteNode {
   var startPosition = CGPoint()
}

class VulnerableGhostNode : GhostNode {
   static var consumptionPoints = 200 // Number of points for eating a vulnerable ghost
   static let consumptionDeltaPoints = 200 // Increase in points for each consecutive ghost that's eaten

   var invulnerableNode : GhostNode?
}

/// Make the Action that controls Ghost behavior. In future, consider different Actions for each ghost so they have "personality".
func makeGhostAction(node : GhostNode) -> SKAction {
   return SKAction.repeatForever(SKAction.sequence(
      [SKAction.wait(forDuration: ghostDecisionPeriodSeconds),
       SKAction.run {
          let dx = node.physicsBody!.velocity.dx
          let dy = node.physicsBody!.velocity.dy
          if abs(dx) < ghostSpeed && abs(dy) < ghostSpeed {
             let direction = PacManScene.Direction.allCases.randomElement()!
             var newVelocity = PacManScene.directionVectors[direction.rawValue]
             newVelocity.dx *= ghostSpeed; newVelocity.dy *= ghostSpeed
             node.physicsBody!.velocity = newVelocity
              ghostDecisionPeriodSeconds = 0.001
          }
       }]))
}

func replaceGhostWithVulnerableGhost(_ ghost : GhostNode) {
   if nil != ghost.parent {
      let newGhost = PacManScene.vulnerableGhostPrototype!.copy() as! VulnerableGhostNode
      newGhost.invulnerableNode = ghost
      newGhost.position = ghost.position
      ghost.parent!.addChild(newGhost)
      ghost.removeFromParent()
      newGhost.run(makeGhostAction(node: newGhost))
      DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
         if nil != newGhost.parent {
            ghost.position = newGhost.position
            newGhost.parent!.addChild(ghost)
            newGhost.removeFromParent()
            VulnerableGhostNode.consumptionPoints = 200 // Reset to eliminate bonus
         }
      }
   }
}

func replaceVulnerableGhostWithEyes(_ vulnerableGhost : VulnerableGhostNode) {
   if nil != vulnerableGhost.parent {
      VulnerableGhostNode.consumptionPoints += VulnerableGhostNode.consumptionDeltaPoints
      let newEyesNode = PacManScene.eyesPrototype!.copy() as! SKSpriteNode
      newEyesNode.position = vulnerableGhost.position
      vulnerableGhost.parent!.addChild(newEyesNode)
      vulnerableGhost.removeFromParent()
      newEyesNode.run(SKAction.sequence([SKAction.move(to: vulnerableGhost.invulnerableNode!.startPosition, duration: 3),
                                             SKAction.run {
         vulnerableGhost.invulnerableNode!.position = newEyesNode.position
         newEyesNode.parent!.addChild(vulnerableGhost.invulnerableNode!)
         newEyesNode.removeFromParent()
      }]))
   }
}


func initGhosts(scene: PacManScene, names: [String]) {
    for name in names {
        let existingGhostNode = (scene.childNode(withName: name) as? GhostNode)!
        existingGhostNode.startPosition = existingGhostNode.position
        existingGhostNode.physicsBody = SKPhysicsBody(rectangleOf: existingGhostNode.size)
        existingGhostNode.physicsBody!.categoryBitMask = PacManScene.PhysicsCategory.Ghost
        existingGhostNode.physicsBody!.collisionBitMask = PacManScene.PhysicsCategory.Wall | PacManScene.PhysicsCategory.Ghost
        existingGhostNode.physicsBody!.contactTestBitMask = PacManScene.PhysicsCategory.PacMan | PacManScene.PhysicsCategory.PowerUp | PacManScene.PhysicsCategory.Ghost

        existingGhostNode.run(makeGhostAction(node: existingGhostNode))
        scene.namedGhosts[name] = existingGhostNode
    }

    scene.physicsWorld.contactDelegate = scene
}


extension PacManScene {
    
    struct PhysicsCategory {
        
           static let None: UInt32 = 0
           static let PacMan: UInt32 = 0b1
           static let Ghost: UInt32 = 0b10
           static let Wall: UInt32 = 0b100
           static let PowerUp: UInt32 = 0b1000
       }
   
    func handleGhostCollision(_ contact: SKPhysicsContact) {
        let categoryA = contact.bodyA.categoryBitMask
        let categoryB = contact.bodyB.categoryBitMask
        
        if (categoryA == PhysicsCategory.Ghost && categoryB == PhysicsCategory.Ghost) {
            // Handle ghost-to-ghost collision
            if let nodeA = contact.bodyA.node as? GhostNode, let nodeB = contact.bodyB.node as? GhostNode {
                print("\(nodeA.name ?? "") and \(nodeB.name ?? "") collided")
                ghostDecisionPeriodSeconds = 0.01
            }
        }
        else {
            // Handle other collisions
        }
    }

}
