//
//  Boid.swift
//  Boids
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Boid: CCSprite {
  
  let VISIBLE_DIS : CGFloat = 60
  let CAUTION_DIS : CGFloat = 20
  let MAX_VELOCITY : CGFloat = 1.5
  
  //vars for different boid behaviors
  //lower number = higher effect
  let COHESION : CGFloat = 900
  let REPULSION : CGFloat = 150
  let VEL_MATCHING : CGFloat = 600
  
  var velocity = CGPoint()
  var delegate : BoidDelegate!

  override func update(delta: CCTime) {
    speedCheck()
    position = sumOf([velocity,position])
    position = modulo(position)
    
    rotation = atan2(Float(velocity.x), Float(velocity.y)) * 180 / Float(M_PI)
  }
  
  private func speedCheck(){
    let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    velocity = speed < MAX_VELOCITY ? velocity : CGPoint(x: velocity.x / speed * MAX_VELOCITY, y: velocity.y / speed * MAX_VELOCITY)
  }
  
  private func modulo(point:CGPoint) -> CGPoint{
    let newX = point.x < 0 ? screenWidth + (point.x % screenWidth) : point.x % screenWidth
    let newY = point.y < 0 ? screenHeight + (point.y % screenHeight) : point.y % screenHeight
    return CGPoint(x: newX, y: newY)
  }
  
  private func sumOf(points:[CGPoint]) -> CGPoint{
    var sum = CGPoint(x: 0, y: 0)
    for point in points{
      sum = CGPoint(x: sum.x + point.x, y: sum.y + point.y)
    }
    return sum
  }
  
  // Boids swim toward other nearby boids.

  
  // Boids keep a small distance from nearby boids.

  
  // Boids match velocity with nearby boids.

  
}

protocol BoidDelegate {
  func getBoidPositionsWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
  func getBoidVelocitiesWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
}