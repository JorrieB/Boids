//
//  Boid.swift
//  Boids
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Boid: CCSprite {
  
  let VISIBLE_DIS : Float = 75
  let CAUTION_DIS : Float = 10
  
  var velocity = CGPoint()
  var delegate : BoidDelegate!

  override func update(delta: CCTime) {
    let v1 = rule1()
    let v2 = rule2()
    let v3 = rule3()
    
    velocity = sumOf([velocity,v1,v2,v3])
    position = sumOf([velocity,position])
    position = CGPoint(x: position.x % screenWidth , y: position.y % screenHeight)
  }
  
  private func sumOf(points:[CGPoint]) -> CGPoint{
    var sum = CGPoint(x: 0, y: 0)
    for point in points{
      sum = CGPoint(x: sum.x + point.x, y: sum.y + point.y)
    }
    return sum
  }
  
  // Boids try to fly towards the center of neighbouring boids.
  func rule1() -> CGPoint {
    
    return CGPoint()
  }
  
  // Boids try to keep a small distance away from other boids.
  func rule2() -> CGPoint {
    return CGPoint()
  }
  
  // Boids try to match velocity with nearby boids.
  func rule3() -> CGPoint {
    return CGPoint()
  }
  
  func averageBoid(positions: [Boid]) -> CGPoint{
    return CGPoint()
  }
  
}

protocol BoidDelegate {
  func getBoidsWithinDistance(x:Float, ofBoid:Boid) -> [Boid]
}