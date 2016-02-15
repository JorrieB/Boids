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
  let NUM_BOIDS : Int = 30;
  let START_VELOCITY_MAGNITUDE : Double = 0.25
  
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
    boid.delegate = self
    return boid
  }
  
  //Generates a random velocity vector of magnitude START_VELOCITY_MAGNITUDE
  private func generateVelocity() -> CGPoint {
    let randX = drand48() * 2 - 1 // get a value between -1 and 1
    let correspondingY = drand48() < 0.5 ? sqrt(1 - randX*randX) : -sqrt(1 - randX*randX) //flip a coin to see what the direction of the y value is
    let vector = CGPoint(x: randX * START_VELOCITY_MAGNITUDE, y: correspondingY * START_VELOCITY_MAGNITUDE) //multiply determined unit vector with start speed
    return vector
  }
  
}

extension MainScene : BoidDelegate {
  
  func getBoidVelocitiesWithin(x: CGFloat, ofBoid: Boid) -> [CGPoint] {
    var targetVelocities = [CGPoint]()
    for boid in BOIDS{
      if boid != ofBoid{
        let possiblePoint = checkBounds(ofBoid, boid2: boid, delta: x)
        if possiblePoint.isValid {
          targetVelocities.append(boid.velocity)
        }
      }
    }
    return targetVelocities
  }
  
  func getBoidPositionsWithin(x: CGFloat, ofBoid: Boid) -> [CGPoint] {
    var targetPoints = [CGPoint]()
    for boid in BOIDS{
      if boid != ofBoid{
        let possiblePoint = checkBounds(ofBoid, boid2: boid, delta: x)
        if possiblePoint.isValid {
          targetPoints.append(possiblePoint.point)
        }
      }
    }
    return targetPoints
  }
  
  private func checkBounds(boid1:Boid, boid2:Boid, delta:CGFloat) -> (isValid:Bool, point:CGPoint){
    let thresholdLeft = boid1.position.x - delta
    let thresholdRight = boid1.position.x + delta
    let thresholdBottom = boid1.position.y - delta
    let thresholdTop = boid1.position.y + delta
    
    let correctedX = correctForOverlap(screenWidth, threshLow: thresholdLeft, threshHigh: thresholdRight, point: boid2.position.x)
    let correctedY = correctForOverlap(screenHeight, threshLow: thresholdBottom, threshHigh: thresholdTop, point: boid2.position.y)
    
    return (correctedX.inBounds && correctedY.inBounds,CGPoint(x: correctedX.value, y: correctedY.value))
  }
  
  private func correctForOverlap(upperLimit:CGFloat, threshLow: CGFloat, threshHigh: CGFloat, point: CGFloat) -> (inBounds:Bool,value:CGFloat){
    var correctedValue : CGFloat?
    if threshLow < 0{
      if point > upperLimit + threshLow{
        correctedValue = point - upperLimit
      } else if point < threshHigh {
        correctedValue = point
      }
    } else if threshHigh > upperLimit {
      if point < threshHigh - upperLimit {
        correctedValue = upperLimit + point
      } else if point > threshLow{
        correctedValue = point
      }
    } else {
      if point > threshLow && point < threshHigh {
        correctedValue = point
      }
    }
    if (correctedValue != nil){
      return (true, correctedValue!)
    }
    return (false, 0)
  }

}

//Unit tests
extension MainScene {
  //correctForOverlap(...)
  func testOverlapCorrection(){
    NSLog("Standard in: \(true == correctForOverlap(100, threshLow: 40, threshHigh: 60, point: 50).inBounds)")
    NSLog("Standard out: \(false == correctForOverlap(100, threshLow: 40, threshHigh: 60, point: 30).inBounds)")
    NSLog("Out the top in bottom: \(true == correctForOverlap(100, threshLow: 90, threshHigh: 110, point: 5).inBounds)")
    NSLog("Out the top in top: \(true == correctForOverlap(100, threshLow: 90, threshHigh: 110, point: 95).inBounds)")
    NSLog("Out the top out: \(false == correctForOverlap(100, threshLow: 90, threshHigh: 110, point: 80).inBounds)")
    NSLog("Out the bottom in top: \(true == correctForOverlap(100, threshLow: -10, threshHigh: 10, point: 95).inBounds)")
    NSLog("Out the bottom in bottom: \(true == correctForOverlap(100, threshLow: -10, threshHigh: 10, point: 5).inBounds)")
    NSLog("Out the bottom out: \(false == correctForOverlap(100, threshLow: -10, threshHigh: 10, point: 45).inBounds)")
  }
  func testOverlapValues(){
    NSLog("Standard in: \(50 == correctForOverlap(100, threshLow: 40, threshHigh: 60, point: 50).value)")
    NSLog("Standard out: \(0 == correctForOverlap(100, threshLow: 40, threshHigh: 60, point: 30).value)")
    NSLog("Out the top in bottom: \(105 == correctForOverlap(100, threshLow: 90, threshHigh: 110, point: 5).value)")
    NSLog("Out the top in top: \(95 == correctForOverlap(100, threshLow: 90, threshHigh: 110, point: 95).value)")
    NSLog("Out the top out: \(0 == correctForOverlap(100, threshLow: 90, threshHigh: 110, point: 80).value)")
    NSLog("Out the bottom in top: \(-5 == correctForOverlap(100, threshLow: -10, threshHigh: 10, point: 95).value)")
    NSLog("Out the bottom in bottom: \(5 == correctForOverlap(100, threshLow: -10, threshHigh: 10, point: 5).value)")
    NSLog("Out the bottom out: \(0 == correctForOverlap(100, threshLow: -10, threshHigh: 10, point: 45).value)")
  }
}