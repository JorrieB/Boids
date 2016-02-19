//
//  Boid.swift
//  Boids
//
//  Created by Jottie Brerrin on 2/14/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Boid: CCSprite {
  
  let MAX_VELOCITY : CGFloat = 1.5
  
  var velocity = CGPoint()
  var delegate : BoidDelegate!

  override func update(delta: CCTime) {
    
    speedCheck()
    position = sumOf([velocity,position]) //update position by velocity
    position = modulo(position)
    
    rotation = atan2(Float(velocity.x), Float(velocity.y)) * 180 / Float(M_PI)
  }
  
  //Limits magnitude of boid velocity
  private func speedCheck(){
    let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    velocity = speed < MAX_VELOCITY ? velocity : CGPoint(x: velocity.x / speed * MAX_VELOCITY, y: velocity.y / speed * MAX_VELOCITY)
  }
  
  //Used to wrap boids around screen
  private func modulo(point:CGPoint) -> CGPoint{
    let newX = point.x < 0 ? screenWidth + (point.x % screenWidth) : point.x % screenWidth
    let newY = point.y < 0 ? screenHeight + (point.y % screenHeight) : point.y % screenHeight
    return CGPoint(x: newX, y: newY)
  }
  
  //Returns the sum of an array of points
  private func sumOf(points:[CGPoint]) -> CGPoint{
    var sum = CGPoint(x: 0, y: 0)
    for point in points{
      sum = CGPoint(x: sum.x + point.x, y: sum.y + point.y)
    }
    return sum
  }
  

  
}

protocol BoidDelegate {
  func getBoidPositionsWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
  func getBoidVelocitiesWithin(x:CGFloat, ofBoid:Boid) -> [CGPoint]
}