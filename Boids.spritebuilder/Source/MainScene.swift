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
    }
  }
  
  private func generateBoid() -> Boid {
    let boid = CCBReader.load("Boid") as! Boid
    boid.position = CGPoint(x: CGFloat(drand48()) * screenWidth, y: CGFloat(drand48()) * screenHeight)
    boid.velocity = generateVelocity()
    return boid
  }
  
  private func generateVelocity() -> CGPoint {
    let randX = drand48()
    let correspondingY = sqrt(1 - randX*randX)
    let vector = CGPoint(x: randX * START_VELOCITY_MAGNITUDE, y: correspondingY * START_VELOCITY_MAGNITUDE)
    return vector
  }
  
}

extension MainScene : BoidDelegate {
  
  func getBoidsWithinDistance(x: Float, ofBoid: Boid) -> [Boid] {
    let boids = [Boid]()
    
    //get boids within distance, including those on the other side of the screen
    
    return boids
  }
  
  private func getDistanceBetween(boid1:Boid, boid2:Boid) -> Float{
    return 0.0
  }
  
}
