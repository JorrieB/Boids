//
//  MainScene.swift
//  MainScene
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

var screenWidth,screenHeight : CGFloat!

class MainScene: CCNode {
  let NUM_BOIDS : Int = 20;
  let START_VELOCITY_MAGNITUDE : Double = 0.5
  
  var BOIDS = [Boid]()
  
  override func onEnter() {
    super.onEnter()
    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
      let screenSize: CGRect = UIScreen.mainScreen().bounds
      screenWidth = screenSize.width / 2
      screenHeight = screenSize.height / 2
    } else {
      let screenSize: CGRect = UIScreen.mainScreen().bounds
      screenWidth = screenSize.width / 2 * UIScreen.mainScreen().scale
      screenHeight = screenSize.height / 2 * UIScreen.mainScreen().scale
    }
    
    for (var i = 0; i < NUM_BOIDS; i++){
      let boid = generateBoid()
      addChild(boid)
      BOIDS.append(boid)
    }
  }
  
  private func generateBoid() -> Boid {
    let boid = CCBReader.load("Boid") as! Boid
    boid.position = CGPoint(x: CGFloat(drand48()) * screenWidth, y: CGFloat(drand48()) * screenHeight)
    boid.velocity = generateVelocity()
//    boid.velocity = CGPoint(x: -1, y: -1)
    return boid
  }
  
  private func generateVelocity() -> CGPoint {
    let randX = drand48() * 2 - 1
    let correspondingY = drand48() < 0.5 ? sqrt(1 - randX*randX) : -sqrt(1 - randX*randX)
    let vector = CGPoint(x: randX * START_VELOCITY_MAGNITUDE, y: correspondingY * START_VELOCITY_MAGNITUDE)
    return vector
  }
  
}

extension MainScene : BoidDelegate {
  
  func getBoidsWithinDistance(x: Float, ofBoid: Boid) -> [Boid] {
    var boids = [Boid]()
    
    for boid in BOIDS {
      if boid != ofBoid && getDistanceBetween(boid, boid2: ofBoid) < x {
        boids.append(boid)
      }
    }
    
    return boids
  }
  
  private func getDistanceBetween(boid1:Boid, boid2:Boid) -> Float{
    return 0.0
  }
  
}
